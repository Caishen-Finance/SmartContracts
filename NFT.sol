// SPDX-License-Identifier: MIT
pragma solidity <=0.8.5;

import "node_modules/@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "node_modules/@openzeppelin/contracts/token/ERC20/ERC20.sol";


/*

    All of it is yet to be tested i dont know if it works properly i am going to test it ASAP


*/
contract NFT is ERC271{

    uint256 public tokenCouter = 0;
    struct drawNftInfo{
        address[] participants;
        mapping(address => bool) isIn;
        uint amountOfParticipants;
        uint numberOfWinners;
        address[] winners;
    }
    mapping(string => drawNftInfo) public NFTData;

    function createNFT(string memory tokenURI, address nftOwner) public returns(uint256){
        uint256 newItemID = tokenCouter;
        _safeMint(nftOwner, newItenID);
        _setTokenURI(newItemID, tokenURI);
        tokenCouter++;
        return newItemID;
    }

    function createNftGame(string memory gameID, uint numberOfWinners) public returns(bool){
        NFTData[gameID].numberOfWinners = numberOfWinners;
        return true;
    }

    function registerToNft(string memory gameID) public returns(bool){
        require(NFTData[gameID].isIn[msg.sender] == false);
        require(NFTData[gameID].numberOfWinners > 0);
        NFTData[gameID].participants.push(msg.sender);
        NFTData[gameID].amountOfParticipants++;
        return true;
    }

    function randomNFT(string memory gameID) private view returns (uint) {
        return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp, NFTData[gameID].participants)));
    }

    function drawWinner(string memory gameID) public returns(bool){
        uint lenght = NFTData[gameID].amountOfParticipants;
        uint index = randomNFT(gameID)%lenght;
        address winner = NFTData[gameID].participants[index];
        NFTData[gameID].winners.push(winner);
        createNFT("...",winner); // Here idk what our URI will be so i left it with dots
        return true;
    }

    function distributeNFTs(string memory gameID) public returns(bool){
        uint n = NFTData[gameID].amountOfPeople;
        for (uint i = 0; i <n; i++){
            drawWinner(gameID);
        }
        return true;
    }

}