// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PublicServiceRequest {
    struct ServiceRequest {
        uint256 requestId;
        string serviceType;
        string description;
        address requester;
        RequestStatus status;
        uint256 requestDate;
        string feedback;
    }
    
    enum RequestStatus { Pending, InProgress, Completed, Rejected }
    
    mapping(uint256 => ServiceRequest) public serviceRequests;
    uint256 public requestCounter;
    address public governmentOfficial;
    
    event RequestSubmitted(uint256 indexed requestId, address indexed requester);
    event RequestStatusUpdated(uint256 indexed requestId, RequestStatus status);
    
    constructor() {
        governmentOfficial = msg.sender;
        requestCounter = 0;
    }
    
    modifier onlyOfficial() {
        require(msg.sender == governmentOfficial, "Only government official can perform this action");
        _;
    }
    
    function submitRequest(string memory _serviceType, string memory _description) public {
        requestCounter++;
        
        serviceRequests[requestCounter] = ServiceRequest({
            requestId: requestCounter,
            serviceType: _serviceType,
            description: _description,
            requester: msg.sender,
            status: RequestStatus.Pending,
            requestDate: block.timestamp,
            feedback: ""
        });
        
        emit RequestSubmitted(requestCounter, msg.sender);
    }
    
    function updateRequestStatus(uint256 _requestId, RequestStatus _status, string memory _feedback) public onlyOfficial {
        require(_requestId <= requestCounter, "Invalid request ID");
        
        ServiceRequest storage request = serviceRequests[_requestId];
        request.status = _status;
        request.feedback = _feedback;
        
        emit RequestStatusUpdated(_requestId, _status);
    }
    
    function getRequestDetails(uint256 _requestId) public view returns (
        string memory serviceType,
        string memory description,
        address requester,
        RequestStatus status,
        uint256 requestDate,
        string memory feedback
    ) {
        ServiceRequest storage request = serviceRequests[_requestId];
        return (
            request.serviceType,
            request.description,
            request.requester,
            request.status,
            request.requestDate,
            request.feedback
        );
    }
}