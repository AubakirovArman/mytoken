
// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Metadata.sol";

/// @custom:security-contact armanibadboy@gmail.com
contract AUBAKIROVARMAN is Initializable, ERC721Upgradeable, ERC721URIStorageUpgradeable, OwnableUpgradeable {
    mapping(uint256 => uint256) private itemPrices;
    mapping(uint256 => bool) private itemForSale;
    uint256 private nextItemId;
    
    struct NFT {
        string ipfsHash;
        uint256 price;
        bool isForSale;
    }
    mapping(uint256 => NFT) private _nfts;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize() initializer public {
        __ERC721_init("AUBAKIROVARMANFORTECHCULTURE", "ARMANINFT");
        __ERC721URIStorage_init();
        __Ownable_init();
    }

    
    function _baseURI() internal pure override returns (string memory) {
        return "https://ipfs.io/ipfs/";
    }

    function createItem(string memory ipfsHash) public returns  (uint256) {
        nextItemId++;
        _mint(msg.sender, nextItemId);
        _setTokenURI(nextItemId, ipfsHash);
        _nfts[nextItemId] = NFT(ipfsHash, 0, false);
        return nextItemId;
    }

    // выставление на продажу
    function listItem(uint256 itemId, uint256 price) public {
        require(ownerOf(itemId) == msg.sender, "You are not the owner of this item.");
        itemPrices[itemId] = price;
        itemForSale[itemId] = true;
    }
    // отмена 
    function cancel(uint256 itemId) public {
        require(ownerOf(itemId) == msg.sender, "You are not the owner of this item.");
        itemForSale[itemId] = false;
    }
    //  покупка 
    function buyItem(uint256 itemId) public payable {
        require(itemForSale[itemId], "This item is not for sale.");
        require(msg.value == itemPrices[itemId], "The amount sent is not equal to the item price.");
        address owner = ownerOf(itemId);
        _transfer(owner, msg.sender, itemId);
        itemForSale[itemId] = false;
        payable(owner).transfer(msg.value);
    }

    // перевод
    function transfer(address to,uint256 itemId)public onlyOwner{
        address owner = ownerOf(itemId);
        _transfer(owner, to, itemId);
        itemForSale[itemId] = false;
    }
    // The following functions are overrides required by Solidity.
    function _burn(uint256 tokenId) internal override(ERC721Upgradeable, ERC721URIStorageUpgradeable) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)public view override (ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory){
        return super.tokenURI(tokenId);
    }
    
    function supportsInterface(bytes4 interfaceId) public view override(ERC721Upgradeable) returns (bool) {
        return super.supportsInterface(interfaceId) || interfaceId == type(IERC721Metadata).interfaceId;
    }
}
