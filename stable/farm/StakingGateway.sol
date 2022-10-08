// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}
interface AggregatorV3Interface {
  function latestRoundData()
    external
    view
    returns (
      uint80 roundId,
      int256 answer,
      uint256 startedAt,
      uint256 updatedAt,
      uint80 answeredInRound
    );
}
interface ICurvePool{
    function get_virtual_price() external view returns(uint);
    function calc_token_amount(uint[2] memory _amounts, bool _is_deposit) external view returns(uint);
    function balances(uint i) external view returns(uint);
    function totalSupply() external view returns (uint);
    function calc_withdraw_one_coin(uint256 _token_amount, int128 i) external view returns(uint);
    function balanceOf(address account) external view returns (uint);
}
interface IStakingRewards {
    // Views

    function balanceOf(address account) external view returns (uint);

    function earned(address account) external view returns (uint);

    function getRewardForDuration() external view returns (uint);

    function lastTimeRewardApplicable() external view returns (uint);

    function rewardPerToken() external view returns (uint);

    function rewardsDistribution() external view returns (address);

    function rewardsToken() external view returns (address);

    function totalSupply() external view returns (uint);

    function rewardRate() external view returns(uint);

    function periodFinish() external view returns(uint);

    function rewardsDuration() external view returns(uint);

    // Mutative

    function exit() external;

    function getReward() external;

    function stake(uint amount) external;

    function withdraw(uint amount) external;
}
contract StakingGateway{
    using SafeMath for uint;
    IStakingRewards public stakingRewards=IStakingRewards(0x61B71689684800f73eBb67378fc2e1527fbDC3b3);
    ICurvePool public torPool=ICurvePool(0x24699312CB27C26Cfc669459D670559E5E44EE60);
    ICurvePool public c2pool=ICurvePool(0x27E611FD27b276ACbd5Ffd632E5eAEBEC9761E40);
    address public owner;

    constructor(){
        owner=msg.sender;
    }

    function getStakingInfo(address wallet,uint amount) external view returns(
        uint _tvl,//1e18
        uint _apr,//1e8
        uint _begin,
        uint _finish,
        uint _optimalTorAmount,
        uint _optimalDaiAmount,
        uint _optimalUsdcAmount,
        uint _torWithdrawAmount,
        uint _daiWithdrawAmount,
        uint _usdcWithdrawAmount,
        uint _earnedRewardAmount
    ){
        _tvl = stakingRewards.totalSupply().mul(torPool.get_virtual_price()).div(1e18);
        _apr = stakingRewards.rewardRate().mul(31536000).mul(assetPrice()).div(_tvl);
        _finish = stakingRewards.periodFinish();
        _begin =_finish.sub(stakingRewards.rewardsDuration());
        (_optimalTorAmount,_optimalDaiAmount,_optimalUsdcAmount)=calOptimal(amount);
        (_torWithdrawAmount,_daiWithdrawAmount,_usdcWithdrawAmount,_earnedRewardAmount)=calWithdrawAndEarned(wallet);
    }
    function setStakingRewards(address _stakingRewards) external{
        require(msg.sender==owner,"not owner");
        stakingRewards=IStakingRewards(_stakingRewards);
    }
    function setTorPool(address _torPool) external{
        require(msg.sender==owner,"not owner");
        torPool=ICurvePool(_torPool);
    }
    function setOwner(address _owner) external{
        require(msg.sender==owner,"not owner");
        owner=_owner;
    }
    function calWithdrawAndEarned(address wallet) public view returns(
        uint _torWithdrawAmount,
        uint _daiWithdrawAmount,
        uint _usdcWithdrawAmount,
        uint _earnedRewardAmount){
        uint bal=stakingRewards.balanceOf(wallet);
        if(bal==0)return (0,0,0,stakingRewards.earned(wallet));
        _torWithdrawAmount=torPool.calc_withdraw_one_coin(bal,0);
        uint daiusdc=torPool.calc_withdraw_one_coin(bal,1);
        if(daiusdc==0)return (_usdcWithdrawAmount,0,0,stakingRewards.earned(wallet));
        _daiWithdrawAmount=c2pool.calc_withdraw_one_coin(daiusdc,0);
        _usdcWithdrawAmount=c2pool.calc_withdraw_one_coin(daiusdc,1);
        _earnedRewardAmount=stakingRewards.earned(wallet);
    }
    function calOptimal(uint amount) public view returns(uint _optimalTor,uint _optimalDai,uint _optimalUsdc){
        if(amount==0)return(0,0,0);
        uint tor=torPool.balances(0);//1e18
        uint daiusdc=torPool.balances(1);//1e18
        uint dai=daiusdc.mul(c2pool.balances(0)).div(c2pool.totalSupply());//1e18
        uint usdc=daiusdc.mul(c2pool.balances(1)).div(c2pool.totalSupply()).mul(1e12);//1e18
        if(dai<=usdc&&dai<=tor){
            if(usdc<=tor){
                (_optimalDai,_optimalUsdc,_optimalTor)=fill(dai,usdc,tor,1,1,2,amount);
            }else{
                (_optimalDai,_optimalTor,_optimalUsdc)=fill(dai,tor,usdc,1,2,1,amount);
            }
        }else if(usdc<=dai&&usdc<=tor){
            if(dai<=tor){
                (_optimalUsdc,_optimalDai,_optimalTor)=fill(usdc,dai,tor,1,1,2,amount);
            }else{
                (_optimalUsdc,_optimalTor,_optimalDai)=fill(usdc,tor,dai,1,2,1,amount);
            }
        }else if(tor<=dai&&tor<=usdc){
            if(dai<=usdc){
                (_optimalTor,_optimalDai,_optimalUsdc)=fill(tor,dai,usdc,2,1,1,amount);
            }else{
                (_optimalTor,_optimalUsdc,_optimalDai)=fill(tor,usdc,dai,2,1,1,amount);
            }
        }
    }
    function fill(
        uint coin1,uint coin2,uint coin3,
        uint factor1,uint factor2,uint factor3,
        uint amount
    ) public pure returns(
        uint _coin1,
        uint _coin2,
        uint _coin3
    ){
        require(coin1<=coin2&&coin2<=coin3,"coin1 coin2 coin3 not in asending order");
        uint oamount=amount;
        if(amount<=coin2.sub(coin1).mul(factor1)) _coin1=amount;
        else{
            _coin1=coin2.sub(coin1).mul(factor1);
            amount=amount.sub(coin2.sub(coin1).mul(factor1));
            if(amount<=coin3.sub(coin2).mul(factor1.add(factor2))){
                _coin1=_coin1.add(amount.mul(factor1).div(factor1.add(factor2)));
                _coin2=amount.mul(factor2).div(factor1.add(factor2));
            }else{
                _coin1=_coin1.add(coin3.sub(coin2).mul(factor1));
                _coin2=coin3.sub(coin2).mul(factor2);
                amount=amount.sub(coin3.sub(coin2).mul(factor1.add(factor2)));
                if(amount>0){
                    _coin1=_coin1.add(amount.mul(factor1).div(factor1.add(factor2).add(factor3)));
                    _coin2=_coin2.add(amount.mul(factor2).div(factor1.add(factor2).add(factor3)));
                    _coin3=amount.mul(factor3).div(factor1.add(factor2).add(factor3));
                }
            }
        }
        if(oamount>_coin1.add(_coin2).add(_coin3))_coin1=_coin1.add(oamount.sub(_coin1.add(_coin2).add(_coin3)));
    }
    function calPoolToken(uint torAmount,uint daiAmount,uint usdcAmount) public view returns(uint poolTokenAmount){
        uint[2] memory tokens;
        tokens[0]=daiAmount;
        tokens[1]=usdcAmount;
        uint daiusdcAmount=c2pool.calc_token_amount(tokens,true);
        tokens[0]=torAmount;
        tokens[1]=daiusdcAmount;
        poolTokenAmount=torPool.calc_token_amount(tokens,true);
    }
    //percentage 1e8 100%=1=1e8
    function calBonusOrSlipage(uint torAmount,uint daiAmount,uint usdcAmount) external view returns(uint percentage){
        uint lpAmount=calPoolToken(torAmount,daiAmount,usdcAmount);
        percentage=lpAmount.mul(torPool.get_virtual_price()).div(1e10).div(torAmount.add(daiAmount).add(usdcAmount.mul(1e12)));//1e8
    }
    function assetPrice() public view returns (uint) {
        ( , int price, , , ) = AggregatorV3Interface(0xf4766552D15AE4d256Ad41B6cf2933482B0680dc).latestRoundData();
        return uint(price);
    }
}
