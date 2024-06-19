// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";
import {IERC20} from "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

/**
 * @title PayLink
 * @dev A contract for managing global and fixed payment links and invoices.
 */
contract PayLink is Initializable, ReentrancyGuardUpgradeable {
    address private deployer;
    address private cUsdTokenAddress;
    uint256 public globalLinkFee= 2e18;

    enum statusEnum{
        PENDINDING,
        PAID
    }
    
    struct GlobalPaymentLink {
        address creator;
        string link;
    }
    
    struct FixedPaymentLink {
        address creator;
        string link;
        uint256 amount;
        statusEnum status;
    }

    struct Invoice {
        string invoiceId;
        string productId;
        address from;
        uint256 amount;
        statusEnum status;
    }
    
    mapping(string => GlobalPaymentLink) public globalPaymentLink;
    mapping(string => FixedPaymentLink) public fixedPaymentLink;
    mapping(string => Invoice) public invoice;
    mapping(string => bool) public globalinkIDExist;
    mapping(string => bool) public fixedinkIDExist;
    mapping(string => bool) public invoiceIdExist;
    
    event GlobalPaymentLinkCreated(string link, address creator);
    event FixedPaymentLinkCreated(string link, address creator, uint amount, statusEnum status);
    event ContributionAdded(string link, address contributor, uint256 amount);
    event PaidFixedPayment(string link, address client, uint amount, statusEnum status);
    event InvoiceCreated(
        string invoiceId,
        string productId,
        address from,
        uint256 amount,
        statusEnum status
    );
    event PaidInvoice(string invoiceId, uint256 amount,  statusEnum status);
    
    modifier onlyDeployer() {
        require(msg.sender == deployer, "Only deployer can call this function");
        _;
    }

    /**
     * @dev Initializes the contract by setting the configuration addresses.
     * @param _cUsdTokenAddress Address of the cUSD token contract.
     */
    function initialize(address _cUsdTokenAddress) public initializer {
        require(_cUsdTokenAddress != address(0), "Invalid cUSD token address");
        deployer = msg.sender;
        cUsdTokenAddress = _cUsdTokenAddress;
    }
    
    /**
     * @dev Creates a global payment link.
     * @param linkID The ID of the global payment link.
     */
    function createGlobalPaymentLink(string memory linkID) external nonReentrant {
        require(IERC20(cUsdTokenAddress).balanceOf(msg.sender) >= globalLinkFee, "Insufficient Balance");
        require(!globalinkIDExist[linkID], "Global link ID not exist");

        globalinkIDExist[linkID] = true; 
        globalPaymentLink[linkID] = GlobalPaymentLink({
            creator: msg.sender,
            link: linkID
        });
                
        // Transfer 2 cUSD to deployer as link generation fee(by default)
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, deployer, globalLinkFee); // Assuming cUSD has 18 decimals
        emit GlobalPaymentLinkCreated(linkID, msg.sender);
    }
    
    /**
     * @dev Contributes to a global payment link.
     * @param linkID The ID of the global payment link.
     * @param _amount The amount to contribute.
     */
    function contributeToGlobalPaymentLink(string memory linkID, uint256 _amount) external nonReentrant {
        require( globalinkIDExist[linkID], "Link does not exist");
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, globalPaymentLink[linkID].creator, _amount);

        emit ContributionAdded(linkID, msg.sender, _amount);
    }
    
    /**
     * @dev Creates a fixed payment link.
     * @param linkID The ID of the fixed payment link.
     * @param _amount The amount to be paid through the link.
     */
    function createFixedPaymentLink(string memory linkID, uint256 _amount) external nonReentrant {
        require(IERC20(cUsdTokenAddress).balanceOf(msg.sender) >= _amount, "Insufficient Balance");
        require(!fixedinkIDExist[linkID], "Link does not exist");

        fixedinkIDExist[linkID] = true; 
        fixedPaymentLink[linkID] = FixedPaymentLink({
            creator: msg.sender,
            link: linkID,
            amount: _amount,
            status: statusEnum.PENDINDING
        });

        // Generate a new fixed payment link at 0.5% fee of the link amount (by default)
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, deployer, (_amount * 5)/ 100);

        emit FixedPaymentLinkCreated(linkID, msg.sender, _amount,statusEnum.PENDINDING);
    }
    
    /**
     * @dev Pays a fixed payment link.
     * @param linkID The ID of the fixed payment link.
     */
    function payFixedPaymentLink(string memory linkID) external nonReentrant {
        require(fixedPaymentLink[linkID].status != statusEnum.PAID, "Link already paid");
        require(fixedinkIDExist[linkID], "Link does not exist");

        fixedPaymentLink[linkID].status = statusEnum.PAID;
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, fixedPaymentLink[linkID].creator, fixedPaymentLink[linkID].amount);

        emit PaidFixedPayment(linkID, msg.sender, fixedPaymentLink[linkID].amount, fixedPaymentLink[linkID].status);
    }

    /**
     * @dev Creates an invoice.
     * @param _invoiceId The ID of the invoice.
     * @param _productId The ID of the product.
     * @param _from The address issuing the invoice.
     * @param _amount The amount to be paid.
     */
    function createInvoice(
        string memory _invoiceId,
        string memory _productId,
        address _from,
        uint256 _amount
    ) external nonReentrant {
        require(IERC20(cUsdTokenAddress).balanceOf(msg.sender) >= 0, "Insufficient Balance");
        require(!invoiceIdExist[_invoiceId], "_invoiceId already exists");

        invoiceIdExist[_invoiceId] = true;
        invoice[_invoiceId] = Invoice({
            invoiceId: _invoiceId,
            productId: _productId,
            from: _from,
            amount: _amount,
            status: statusEnum.PENDINDING
        });

        // Generate an invoice at 0.5% fee of the amount(by default)
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, deployer, (_amount * 5)/ 100);

        emit InvoiceCreated(_invoiceId, _productId, _from, _amount, statusEnum.PENDINDING);
    }

    /**
     * @dev Pays an invoice.
     * @param _invoiceId The ID of the invoice.
     */
    function payInvoice(string memory _invoiceId) external nonReentrant {
        require(invoice[_invoiceId].status != statusEnum.PENDINDING, "Invoice already paid");
        require(invoiceIdExist[_invoiceId], "Invoice id does not exist");

        invoice[_invoiceId].status = statusEnum.PAID;
        IERC20(cUsdTokenAddress).transferFrom(msg.sender, invoice[_invoiceId].from, invoice[_invoiceId].amount);

        emit PaidInvoice(invoice[_invoiceId].invoiceId, invoice[_invoiceId].amount, invoice[_invoiceId].status);
    }

    // set the globalLinkFee
    function setGlobalLinkFee(uint _globalLinkFee) external nonReentrant onlyDeployer{
        globalLinkFee = _globalLinkFee;
    }
}
