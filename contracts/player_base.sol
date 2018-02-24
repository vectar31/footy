pragma solidity ^0.4.17;
import "./ownable.sol"
import "./ERC721.sol"
import "./player_access_control.sol"

contract PlayerBase is playerAccessControl {

    // The NewPlayer event is fired when addNewPlayer is called i.e. when a new player is created.
    event NewPlayer(address owner, uint256 playerId, uint256 nationId, uint256 clubId, uint256 stats);

    // Transfer event as defined in current draft of ERC721. Emitted every time a player
    //  ownership is assigned, including NewPlayers.
    event Transfer(address from, address to, uint256 tokenId);

    struct player {
        // The player's stats is packed into these 256-bits
        uint256 stats;

        // The timestamp from the block when this player came into existence.
        uint64 NewPlayerTime;

        // The minimum timestamp after which this player can engage in playing again after an injury.
        uint64 injuryRecoveryTime;


        // The ID of the club and nation of this player, set to 0 for random players.
        uint32 nationId;
        uint32 clubId;

        // Set to the index in the recovery array (see below) that represents
        // the current recovery duration for this player..
        uint16 injuryRecoveryIndex;

    }

    /*** CONSTANTS ***/

    // A lookup table indiplayering the recovery duration after any injury. Range - (1 to 30 days)
    uint32[14] public recovery = [
        uint32(0 days)
        uint32(1 days),
        uint32(2 days),
        uint32(3 days),
        uint32(4 days),
        uint32(5 days),
        uint32(6 days),
        uint32(7 days),
        uint32(8 days),
        uint32(9 days),
        uint32(10 days),
        uint32(11 days),
        uint32(12 days),
        uint32(13 days),
        uint32(14 days),
        uint32(15 days),
        uint32(16 days),
        uint32(17 days),
        uint32(18 days),
        uint32(19 days),
        uint32(20 days),
        uint32(21 days),
        uint32(22 days),
        uint32(23 days),
        uint32(24 days),
        uint32(25 days),
        uint32(26 days),
        uint32(27 days),
        uint32(28 days),
        uint32(29 days),
        uint32(30 days),
    ];

    /*** STORAGE ***/

    // starts from 1, player 0 is me (not a player you want)
    player[] Players;

    // A mapping from player IDs to the address that owns them. All players have
    //  some valid owner address, even random players are created with a non-zero owner.
    mapping (uint256 => address) public playerIndexToOwner;

    // A mapping from owner address to count of tokens that address owns.
    //  Used internally inside balanceOf() to resolve ownership count.
    mapping (address => uint256) ownershipTokenCount;

    mapping (uint256 => address) public playerIndexToApproved;

    SaleClockAuction public saleAuction;

    // Assigns ownership of a specific player to an address.
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        // Since the number of players is capped to 2^32 we can't overflow this
        ownershipTokenCount[_to]++;
        // transfer ownership
        playerIndexToOwner[_tokenId] = _to;
        // When creating new players _from is 0x0, but we can't account that address.
        if (_from != address(0)) {
            ownershipTokenCount[_from]--;
            // clear any previously approved ownership exchange
            delete playerIndexToApproved[_tokenId];
        }
        // Emit the transfer event.
        Transfer(_from, _to, _tokenId);
    }

    function _createplayer(
        uint256 _nationId,
        uint256 _clubId,
        uint256 _stats,
        address _owner
    )
        internal
        returns (uint)
    {
        require(_nationId == uint256(uint32(_nationId)));
        require(_clubId == uint256(uint32(_clubId)));
        
        uint16 injuryRecoveryIndex = 0;

        player memory _player = player({
            stats: _stats,
            NewPlayerTime: uint64(now),
            injuryRecoveryTime: 0,
            nationId: uint32(_nationId),
            clubId: uint32(_clubId),
            injuryRecoveryIndex: injuryRecoveryIndex,
        });
        uint256 newplayerId = Players.push(_player) - 1;

        require(newplayerId == uint256(uint32(newplayerId)));

        // emit the NewPlayer event
        NewPlayer(
            _owner,
            newplayerId,
            uint256(_player.nationId),
            uint256(_player.clubId),
            _player.stats
        );

        // This will assign ownership, and also emit the Transfer event as
        // per ERC721 draft
        _transfer(0, _owner, newplayerId);

        return newplayerId;
    }

}