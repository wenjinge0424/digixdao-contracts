import "./Interfaces.sol";

contract DAO is DAOInterface {

  struct Pledge {
    uint256 startDate;
    uint256 endDate;
    uint256 approve;
    uint256 decline;
    uint256 total;
  }

  struct ProposalInfo {
    address submitter;
    uint8 typeId;
    uint8 status;
    uint256 budget;
    bytes32 document;
  }

  struct Proposal {
    ProposalInfo info;
    Pledge vetting;
    Pledge pledging;
  }

  mapping (bytes32 => Proposal) proposals;

  address public DGXCORE = 0x3ee9779e286a2f12ebe31881ae26c86816e0b942;

  event Propose(bytes32 indexed _proposalId, uint256 indexed _budget);

  function DAO(address _token) {
     
  }

  function submitProposal(uint8 typeId, bytes32 _doc, uint256 _budget) {
    bytes32 _pId = sha3(tx.origin, block.number, now);
    Propose(_pId, _budget);
  }
  
  function vet(address _proposal, bool _vet) {
  }

  function pledge(address _proposal) {
  }

  function resolve(address _proposal) {
  }

}
