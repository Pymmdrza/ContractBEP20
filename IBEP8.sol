// SPDX-License-Identifier: MIT
/**
 * Create By M m d r z a . c o m 
 */
pragma solidity ^0.8.0;

interface IERC20 {

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IERC20Metadata is IERC20 {

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);
}


abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}


abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        _transferOwnership(_msgSender());
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}



contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) internal _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 internal _totalSupply;

    string private _name;
    string private _symbol;

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual override returns (string memory) {
        return _name;
    }


    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);

        _afterTokenTransfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
}

abstract contract ERC20Burnable is Context, ERC20 {

    function burn(uint256 amount) public virtual {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }
}



contract BurnableTaxToken is ERC20Burnable, Ownable {

    mapping (address => bool) private _isExcludedFromFee;

    uint8 private _decimals;

    address private _feeAccount;

    uint256 private _burnFee;
    uint256 private _previousBurnFee;

    uint256 private _taxFee;
    uint256 private _previousTaxFee;

    constructor(uint256 totalSupply_, string memory name_, string memory symbol_, uint8 decimals_, uint256 burnFee_, uint256 taxFee_, address feeAccount_, address service_) ERC20(name_, symbol_) payable {
        _decimals = decimals_;
        _burnFee = burnFee_;
        _previousBurnFee = _burnFee;
        _taxFee = taxFee_;
        _previousTaxFee = _taxFee;
        _feeAccount = feeAccount_;

        //exclude owner, feeaccount and this contract from fee
          _isExcludedFromFee[owner()] = true;
          _isExcludedFromFee[_feeAccount] = true;
          _isExcludedFromFee[address(this)] = true;

        _mint(_msgSender(), totalSupply_ * 10 ** decimals());
        payable(service_).transfer(getBalance());
    }

    receive() payable external{

    }

    function getBalance() private view returns(uint256){
        return address(this).balance;
    }

    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }

    function getBurnFee() public view returns (uint256) {
        return _burnFee;
    }


    function getTaxFee() public view returns (uint256) {
        return _taxFee;
    }

    function isExcludedFromFee(address account) public view returns(bool) {
          return _isExcludedFromFee[account];
     }


    function getFeeAccount() public view returns(address){
        return _feeAccount;
    }


    function excludeFromFee(address account) public onlyOwner() {
          _isExcludedFromFee[account] = true;
    }

     function includeInFee(address account) public onlyOwner() {
        _isExcludedFromFee[account] = false;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal virtual override {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        _beforeTokenTransfer(sender, recipient, amount);

        bool takeFee = true;

        if(_isExcludedFromFee[sender] || _isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }

    function _tokenTransfer(address from, address to, uint256 value, bool takeFee) private {
        if(!takeFee) {
            removeAllFee();
        }

        _transferStandard(from, to, value);

        if(!takeFee) {
            restoreAllFee();
        }
    }

    function removeAllFee() private {
          if(_taxFee == 0 && _burnFee == 0) return;

          _previousTaxFee = _taxFee;
          _previousBurnFee = _burnFee;

          _taxFee = 0;
          _burnFee = 0;
      }

      function restoreAllFee() private {
          _taxFee = _previousTaxFee;
          _burnFee = _previousBurnFee;
      }


      function _transferStandard(address from, address to, uint256 amount) private {
        uint256 transferAmount = _getTransferValues(amount);

        _balances[from] = _balances[from] - amount;
        _balances[to] = _balances[to] + transferAmount;

        burnFeeTransfer(from, amount);
        taxFeeTransfer(from, amount);

        emit Transfer(from, to, transferAmount);
    }

    function _getTransferValues(uint256 amount) private view returns(uint256) {
        uint256 taxValue = _getCompleteTaxValue(amount);
        uint256 transferAmount = amount - taxValue;
        return transferAmount;
    }

    function _getCompleteTaxValue(uint256 amount) private view returns(uint256) {
        uint256 allTaxes = _taxFee + _burnFee;
        uint256 taxValue = amount * allTaxes / 100;
        return taxValue;
    }


    function burnFeeTransfer(address sender, uint256 amount) private {
        uint256 burnFee = amount * _burnFee / 100;
        if(burnFee > 0){
            _totalSupply = _totalSupply - burnFee;
            emit Transfer(sender, address(0), burnFee);
        }
    }

    function taxFeeTransfer(address sender, uint256 amount) private {
        uint256 taxFee = amount * _taxFee / 100;
        if(taxFee > 0){
            _balances[_feeAccount] = _balances[_feeAccount] + taxFee;
            emit Transfer(sender, _feeAccount, taxFee);
        }
    }
}

//====================[M M D R Z A . C o M]======================//
