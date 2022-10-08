// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) =
            target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data)
        internal
        view
        returns (bytes memory)
    {
        return
            functionStaticCall(
                target,
                data,
                "Address: low-level static call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return
            functionDelegateCall(
                target,
                data,
                "Address: low-level delegate call failed"
            );
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) private pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata =
            address(token).functionCall(
                data,
                "SafeERC20: low-level call failed"
            );
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }
}
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
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function mint(address account_, uint256 amount_) external;
    function decimals() external view returns (uint8);
    function burnFrom(address account_, uint256 amount_) external;
}
interface IOwnable {
    function owner() external view returns (address);

    function renounceManagement(string memory confirm) external;

    function pushManagement( address newOwner_ ) external;

    function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPulled( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement(string memory confirm) public virtual override onlyOwner() {
        require(
            keccak256(abi.encodePacked(confirm)) == keccak256(abi.encodePacked("confirm renounce")),
            "Ownable: renouce needs 'confirm renounce' as input"
        );
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyOwner() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
    }
}
interface IUniswapRouter{
    function swapExactTokensForTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external returns (uint256[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}
interface ITORMinter{
    function mintWithDai(uint _daiAmount) external returns(uint _torAmount);
    function mintWithUsdc(uint _usdcAmount) external returns(uint _torAmount);
    function redeemToDai(uint _torAmount) external returns(uint _daiAmount);
    function redeemToUsdc(uint _torAmount) external returns(uint _usdcAmount);
}
interface ITORMinterValues{
    function totalMintFee() external view returns(uint);
    function totalBurnFee() external view returns(uint);
    function totalTorMinted() external view returns(uint);
    function totalTorBurnt() external view returns(uint);
    function totalHecMinted() external view returns(uint);
    function totalHecBurnt() external view returns(uint);
    function lastMintTimestamp() external view returns(uint);
    function lastRedeemTimestamp() external view returns(uint);
}
interface IOldTORMinterValues{
    function totalMinted() external view returns(uint);
    function totalBurnt() external view returns(uint);
}
interface IHECMinter{
    function mintHEC(uint amount) external;
    function burnHEC(uint amount) external;
}
interface ITORMintRedeemStrategy{
    function canMint(address recipient,uint torAmount,address stableToken) external returns(bool);
    function canRedeem(address recipient,uint torAmount,address stableToken) external returns(bool);
}
contract TORMinter is ITORMinter,Ownable{
    using SafeERC20 for IERC20;
    using SafeMath for uint;

    IERC20 dai=IERC20(0x8D11eC38a3EB5E956B052f67Da8Bdc9bef8Abf3E);
    IERC20 usdc=IERC20(0x04068DA6C83AFCFA0e13ba15A6696662335D5B75);
    IERC20 public hec=IERC20(0x5C4FDfc5233f935f20D2aDbA572F770c2E377Ab0);
    IERC20 TOR;
    IHECMinter HECMinter;
    uint public totalMintFee;
    uint public totalBurnFee;
    uint public totalTorMinted;
    uint public totalTorBurnt;
    uint public totalHecMinted;
    uint public totalHecBurnt;
    uint public lastMintTimestamp;
    uint public lastRedeemTimestamp;
    bool upgraded=false;
    ITORMintRedeemStrategy public strategy;
    mapping(IERC20=>IUniswapRouter) routers;

    uint public mintFeeBasisPoints=10;
    uint public redeemFeeBasisPoints=10;
    uint constant UNIT_ONE_IN_BPS=10000;

    constructor(address _HECMinter, address _TOR){
        require(_HECMinter!=address(0));
        HECMinter=IHECMinter(_HECMinter);
        require(_TOR!=address(0));
        TOR=IERC20(_TOR);
        lastMintTimestamp=block.timestamp;
        lastRedeemTimestamp=block.timestamp;
        routers[dai]=IUniswapRouter(0xF491e7B69E4244ad4002BC14e878a34207E38c29); //dai=>spooky
        routers[usdc]=IUniswapRouter(0x16327E3FbDaCA3bcF7E38F5Af2599D2DDc33aE52); //usdc=>spirit
    }
    function upgradeFrom(address oldTorMinter,bool isOldVersion) external onlyOwner(){
        if(!upgraded){
            totalMintFee=ITORMinterValues(oldTorMinter).totalMintFee();
            totalBurnFee=ITORMinterValues(oldTorMinter).totalBurnFee();
            if(isOldVersion){
                totalTorMinted=IOldTORMinterValues(oldTorMinter).totalMinted();
                totalTorBurnt=IOldTORMinterValues(oldTorMinter).totalBurnt();
            }else{
                totalTorMinted=ITORMinterValues(oldTorMinter).totalTorMinted();
                totalTorBurnt=ITORMinterValues(oldTorMinter).totalTorBurnt();
                lastMintTimestamp=ITORMinterValues(oldTorMinter).lastMintTimestamp();
                lastRedeemTimestamp=ITORMinterValues(oldTorMinter).lastRedeemTimestamp();
            }
            totalHecMinted=ITORMinterValues(oldTorMinter).totalHecMinted();
            totalHecBurnt=ITORMinterValues(oldTorMinter).totalHecBurnt();
            upgraded=true;
            }
    }
    function setHec(address _hec) external onlyOwner(){
        require(_hec!=address(0));
        hec=IERC20(_hec);
    }
    function setTOR(address _TOR) external onlyOwner(){
        require(_TOR!=address(0));
        TOR=IERC20(_TOR);
    }
    function setHECMinter(address _HECMinter) external onlyOwner(){
        require(_HECMinter!=address(0));
        HECMinter=IHECMinter(_HECMinter);
    }
    function setMintStrategy(address _strategy) external onlyOwner(){
        require(_strategy!=address(0));
        strategy=ITORMintRedeemStrategy(_strategy);
    }
    function setMintFee(uint _mintFeeBasisPoints) external onlyOwner(){
        require(_mintFeeBasisPoints<=1000,"fee can't be higher than 1000 bps");
        mintFeeBasisPoints=_mintFeeBasisPoints;
    }
    function setRedeemFee(uint _redeemFeeBasisPoints) external onlyOwner(){
        require(_redeemFeeBasisPoints<=1000,"fee can't be higher than 1000 bps");
        redeemFeeBasisPoints=_redeemFeeBasisPoints;
    }
    function setDaiLpSwapRouter(address _swapRouter) external onlyOwner(){
        routers[dai]=IUniswapRouter(_swapRouter);
    }
    function setUsdcLpSwapRouter(address _swapRouter) external onlyOwner(){
        routers[usdc]=IUniswapRouter(_swapRouter);
    }
    function collectFee() external onlyOwner(){
        if(dai.balanceOf(address(this))>0)dai.transfer(owner(),dai.balanceOf(address(this)));
        if(usdc.balanceOf(address(this))>0)usdc.transfer(owner(),usdc.balanceOf(address(this)));
    }

    function convertDecimal(IERC20 from,IERC20 to, uint fromAmount) view public returns(uint toAmount){
        uint8 fromDec=from.decimals();
        uint8 toDec=to.decimals();
        if(fromDec==toDec) toAmount=fromAmount;
        else if(fromDec>toDec) toAmount=fromAmount.div(10**(fromDec-toDec));
        else toAmount=fromAmount.mul(10**(toDec-fromDec));
    }

    function mintWithStable(IERC20 _stableToken,uint _stableAmount) internal returns(uint _torAmount){
        require(address(routers[_stableToken])!=address(0),"unknown stable token");
        require(msg.sender==tx.origin,"mint for EOA only");
        require(address(strategy)!=address(0),"mint redeem strategy is not set");
        _stableToken.safeTransferFrom(msg.sender,address(this),_stableAmount);
        uint amount=_stableAmount.mul(UNIT_ONE_IN_BPS.sub(mintFeeBasisPoints)).div(UNIT_ONE_IN_BPS);
        if(_stableAmount>amount){
            totalMintFee=totalMintFee.add(convertDecimal(_stableToken,TOR,_stableAmount.sub(amount)));
        }
        _stableToken.approve(address(routers[_stableToken]),amount);
        address[] memory path=new address[](2);
        path[0]=address(_stableToken);
        path[1]=address(hec);
        uint[] memory amountOuts=routers[_stableToken].swapExactTokensForTokens(
            amount,
            1,
            path,
            address(this),
            block.timestamp
        );
        require(amountOuts[1]>0,"invalid hec amount from swap");
        hec.approve(address(HECMinter),amountOuts[1]);
        HECMinter.burnHEC(amountOuts[1]);
        totalHecBurnt=totalHecBurnt.add(amountOuts[1]);
        uint tor2mint=convertDecimal(_stableToken,TOR,amount);
        require(strategy.canMint(msg.sender,tor2mint,address(_stableToken))==true,"mint not allowed by strategy");
        TOR.mint(msg.sender,tor2mint);
        totalTorMinted=totalTorMinted.add(tor2mint);
        lastMintTimestamp=block.timestamp;
        _torAmount=tor2mint;
    }

    function mintWithDai(uint _daiAmount) override external returns(uint _torAmount){
        return mintWithStable(dai,_daiAmount);
    }
    
    function mintWithUsdc(uint _usdcAmount) override external returns(uint _torAmount){
        return mintWithStable(usdc,_usdcAmount);
    }

    function redeemToStable(uint _torAmount,IERC20 _stableToken) internal returns(uint _stableAmount){
        require(address(routers[_stableToken])!=address(0),"unknown stable token");
        require(msg.sender==tx.origin,"redeem for EOA only");
        require(address(strategy)!=address(0),"mint redeem strategy is not set");
        require(strategy.canRedeem(msg.sender,_torAmount,address(_stableToken))==true,"redeem not allowed by strategy");
        TOR.burnFrom(msg.sender,_torAmount);
        totalTorBurnt=totalTorBurnt.add(_torAmount);
        lastRedeemTimestamp=block.timestamp;
        uint amountOut=convertDecimal(TOR,_stableToken,_torAmount).mul(UNIT_ONE_IN_BPS.sub(redeemFeeBasisPoints)).div(UNIT_ONE_IN_BPS);
        address[] memory path=new address[](2);
        path[0]=address(hec);
        path[1]=address(_stableToken);
        uint[] memory amounts=routers[_stableToken].getAmountsIn(amountOut, path);
        HECMinter.mintHEC(amounts[0]);
        totalHecMinted=totalHecMinted.add(amounts[0]);
        hec.approve(address(routers[_stableToken]),amounts[0]);
        uint[] memory amountOuts=routers[_stableToken].swapExactTokensForTokens(
            amounts[0],
            1,
            path,
            address(this),
            block.timestamp
        );
        amountOut=amountOuts[1];
        if(_torAmount>convertDecimal(_stableToken,TOR,amountOut)){
            totalBurnFee=totalBurnFee.add(_torAmount.sub(convertDecimal(_stableToken,TOR,amountOut)));
        }
        _stableToken.transfer(msg.sender,amountOut);
        _stableAmount=amountOut;
    }

    function redeemToDai(uint _torAmount) override external returns(uint _daiAmount){
        return redeemToStable(_torAmount,dai);
    }
    function redeemToUsdc(uint _torAmount) override external returns(uint _usdcAmount){
        return redeemToStable(_torAmount,usdc);
    }
}
