contract CoreWallet {

  event Withdraw(address indexed _recipient, uint256 indexed _amount, address indexed _sender);
  event PaymentRequest(uint256 indexed _requestId);
  event Approve(uint256 indexed _requestId);
  event Decline(uint256 indexed _requestId);
  
  enum RequestStatus { Pending, Declined, Approved }

  struct Request {
    RequestStatus status;
    uint256 amount;
    address recipient;
  } 

  mapping (address => bool) approved;
  mapping (address => bool) managers;
  address public owner;
  mapping (uint256 => Request) requests;
  uint256 requestCount = 0;

  modifier ifOwner() {
    if (owner != msg.sender) {
      throw;
    } else {
      _
    }
  }

  modifier ifApproved() {
    if (!approved[msg.sender]) {
      throw;
    } else {
      _
    }
  }

  modifier ifManager() {
    if (!managers[msg.sender]) {
      throw;
    } else {
      _
    }
  }

  modifier ifStatus(RequestStatus _status, uint256 _requestId) {
    if (_status != requests[_requestId].status) {
      throw;
    } else {
      _
    }
  }


  function CoreWallet() {
    approved[msg.sender] = true;
    managers[msg.sender] = true;
    owner = msg.sender;
  }

  function balance() public constant returns (uint256 bal) {
    bal = address(this).balance;
    return bal;
  }

  function authorizeUser(address _user) ifManager returns (bool success) {
    approved[_user] = true;
    success = true;
    return success;
  }

  function unauthorizeUser(address _user) ifManager returns (bool success) {
    approved[_user] = false;
    success = true;
    return success;
  }

  function authorizeManager(address _user) ifOwner returns (bool success) {
    managers[_user] = true;
    success = true;
    return success;
  }

  function unauthorizeManager(address _user) ifOwner returns (bool success) {
    managers[_user] = false;
    success = true;
    return success;
  }

  function withdraw(address _recipient, uint256 _amount) ifManager returns (bool success) {
    if (address(_recipient).send(_amount)) {
      Withdraw(_recipient, _amount, msg.sender);
      success = true;
    } else {
      success = false;
    }
    return success;
  }

  function request(address _recipient, uint256 _amount) ifApproved returns (bool success) {
    if (_amount < balance()) {
      success = false;
    } else {
      requestCount++;
      requests[requestCount].status = RequestStatus.Pending;
      requests[requestCount].amount = _amount;
      requests[requestCount].recipient = _recipient;
      success = true;
      PaymentRequest(requestCount);
    }
    return success;
  }

  function approve(uint256 _requestId) ifManager ifStatus(RequestStatus.Pending, _requestId) returns (bool success) {
    if (address(requests[_requestId].recipient).send(requests[_requestId].amount)) {
      requests[_requestId].status = RequestStatus.Approved;
      success = true;
      Approve(_requestId);
    } else {
      success = false;
    }
    return success;
  }

  function decline(uint256 _requestId) ifManager ifStatus(RequestStatus.Pending, _requestId) returns (bool success) {
    requests[_requestId].status = RequestStatus.Declined;
    success = true;
    Decline(_requestId);
    return success;
  }

}
