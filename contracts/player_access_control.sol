pragma solidity ^0.4.17;
import "./ownable.sol"
import "./ERC721.sol"
contract PlayerAccessControl {
    // Access Control
    // The primary owner(primaryOwner): The primaryOwner can reassign other roles and change the addresses of our dependent smart
    //         contracts. It is also the only role that can unpause the smart contract. It is initially
    //         set to the address that created the smart contract in the KittyCore constructor.
    //  The secondaryOwner: The secondaryOwner can withdraw funds from PlayerCore and its auction contracts.
    //  The primaryOwner can assign any address to any role, the primaryOwner address itself doesn't have the ability to act in those roles. 

    // Updating current contract
    event ContractUpgrade(address newContract);

    // The addresses of the accounts (or contracts) that can execute actions within each roles.
    address public primaryOwnerAddress;
    address public secondaryOwnerAddress;
    
    // Keeps track whether the contract is paused. When that is true, most actions are blocked
    bool public paused = false;

    // Access modifier for primaryOwner-only functionality
    modifier onlyPrimaryOwner() {
        require(msg.sender == primaryOwnerAddress);
        _;
    }

    /// @dev Access modifier for secondaryOwner-only functionality
    modifier onlysecondaryOwner() {
        require(msg.sender == secondaryOwnerAddress);
        _;
    }

    modifier onlyOwnerLevel() {
        require(
            msg.sender == primaryOwnerAddress ||
            msg.sender == secondaryOwnerAddress
        );
        _;
    }

    /// Assigns a new address to act as the primaryOwner. Only available to the current primaryOwner.
    
    function setprimaryOwner(address _newprimaryOwner) external onlyPrimaryOwner {
        require(_newprimaryOwner != address(0));

        primaryOwnerAddress = _newprimaryOwner; // assigns the new address
    }

    function setsecondaryOwner(address _newsecondaryOwner) external onlyPrimaryOwner {
        require(_newsecondaryOwner != address(0));

        secondaryOwnerAddress = _newsecondaryOwner;
    }

    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    modifier whenPaused {
        require(paused);
        _;
    }

    function pause() external onlyOwnerLevel whenNotPaused {
        paused = true;
    }

    function unpause() public onlyPrimaryOwner whenPaused {
        // can't unpause if contract was upgraded
        paused = false;
    }
}
