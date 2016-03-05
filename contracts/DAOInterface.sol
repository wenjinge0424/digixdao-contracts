contract DAOInterface {
  struct Proposal {
    mapping (address => bool) proposers;
    bool completed;
    bool vetted;
    bool pledged;
    mapping (address => uint256) pledges;
    mapping (address => uint256) vets;
  }
}
