// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICitizenIdentity {
    function isCitizenVerified(address _citizenAddress) external view returns (bool);
    function government() external view returns (address);
}

contract PublicServiceRequest {
    struct ServiceRequest {
        uint256 requestId;
        string serviceType;
        string description;
        address requester;
        RequestStatus status;
        uint256 requestDate;
        string response; 
    }
    
    enum RequestStatus { Pending, InProgress, Completed, Rejected }
    
    ICitizenIdentity public citizenIdentityContract;
    mapping(uint256 => ServiceRequest) public serviceRequests;
    uint256 public requestCounter;
    
    event RequestSubmitted(uint256 indexed requestId, address indexed requester, string serviceType);
    event RequestStatusUpdated(uint256 indexed requestId, RequestStatus status, string response);
    
    constructor(address _citizenIdentityContract) {
        require(_citizenIdentityContract != address(0), "Invalid CitizenIdentity contract address");
        citizenIdentityContract = ICitizenIdentity(_citizenIdentityContract);
        requestCounter = 0;
    }
    
    modifier onlyGovernment() {
        require(msg.sender == citizenIdentityContract.government(), "Only government can perform this action");
        _;
    }
    
    modifier onlyVerifiedCitizen() {
        require(citizenIdentityContract.isCitizenVerified(msg.sender), "Only verified citizens can submit requests");
        _;
    }
    
    function submitRequest(string memory _serviceType, string memory _description) public onlyVerifiedCitizen {
        requestCounter++;
        
        serviceRequests[requestCounter] = ServiceRequest({
            requestId: requestCounter,
            serviceType: _serviceType,
            description: _description,
            requester: msg.sender,
            status: RequestStatus.Pending,
            requestDate: block.timestamp,
            response: ""  
        });
        
        emit RequestSubmitted(requestCounter, msg.sender, _serviceType);
    }
    
    function updateRequestStatus(
        uint256 _requestId, 
        RequestStatus _status, 
        string memory _response  
    ) public onlyGovernment {
        require(_requestId > 0 && _requestId <= requestCounter, "Invalid request ID");
        
        ServiceRequest storage request = serviceRequests[_requestId];
        request.status = _status;
        request.response = _response;  
        
        emit RequestStatusUpdated(_requestId, _status, _response);
    }
    
    function getRequestDetails(uint256 _requestId) public view returns (
        string memory serviceType,
        string memory description,
        address requester,
        RequestStatus status,
        uint256 requestDate,
        string memory response  
    ) {
        require(_requestId > 0 && _requestId <= requestCounter, "Invalid request ID");
        
        ServiceRequest storage request = serviceRequests[_requestId];
        return (
            request.serviceType,
            request.description,
            request.requester,
            request.status,
            request.requestDate,
            request.response 
        );
    }
    
    function getRequestsByRequester(address _requester) public view returns (uint256[] memory) {
        uint256[] memory tempRequests = new uint256[](requestCounter);
        uint256 count = 0;
        
        for (uint256 i = 1; i <= requestCounter; i++) {
            if (serviceRequests[i].requester == _requester) {
                tempRequests[count] = i;
                count++;
            }
        }
        
        uint256[] memory result = new uint256[](count);
        for (uint256 i = 0; i < count; i++) {
            result[i] = tempRequests[i];
        }
        
        return result;
    }
    
    function getRequestStatusString(uint256 _requestId) public view returns (string memory) {
        require(_requestId > 0 && _requestId <= requestCounter, "Invalid request ID");
        
        RequestStatus status = serviceRequests[_requestId].status;
        if (status == RequestStatus.Pending) return "Pending";
        if (status == RequestStatus.InProgress) return "In Progress";
        if (status == RequestStatus.Completed) return "Completed";
        if (status == RequestStatus.Rejected) return "Rejected";
        return "Unknown";
    }
}