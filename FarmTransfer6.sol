pragma solidity ^0.4.20;

contract WorkbenchBase {
    event WorkbenchContractCreated(string applicationName, string workflowName, address originatingAddress);
    event WorkbenchContractUpdated(string applicationName, string workflowName, string action, address originatingAddress);

    string internal ApplicationName;
    string internal WorkflowName;

    function WorkbenchBase(string applicationName, string workflowName) internal {
        ApplicationName = applicationName;
        WorkflowName = workflowName;
    }

    function ContractCreated() internal {
        WorkbenchContractCreated(ApplicationName, WorkflowName, msg.sender);
    }

    function ContractUpdated(string action) internal {
        WorkbenchContractUpdated(ApplicationName, WorkflowName, action, msg.sender);
    }
}

contract FarmTransfer6 is WorkbenchBase("FarmTransfer6", "FarmTransfer6") {

    enum StateType { Created, ReadyToTransport, InTransit, Delivered, Available, Selled, Cancelled, Terminated}
    
    StateType public State;
    address public Farmer;
    address public Provider;
    address public Seller;
    address public Buyer;    
    string public Description;
    uint public Price;
    uint public Quantity;
    int public MinTemperature = 0 ;
    int public MaxTemperature = 10;
    uint public MinHumidity = 65;
    uint public MaxHumidity = 85;   
    bool public ComplianceStatus;
    uint public FarmerBalance = 0;
    uint public ProviderBalance = 68;
    uint public SellerBalance = 78;    
    uint public BuyerBalance = 86;

    function FarmTransfer6(string description, uint256 price, uint256 quantity, int mintemp, int maxtemp, uint256 minhumid, uint256 maxhumid) public {
        ComplianceStatus = true;
        Farmer = msg.sender;
        Price = price;
        Quantity = quantity;
        Description = description;
        MaxTemperature = maxtemp;
        MinTemperature = mintemp;
        MinHumidity = minhumid;
        MaxHumidity = maxhumid;
        State = StateType.Created;
        ContractCreated();
    }

    function Terminate() public {
        State = StateType.Terminated;
        ContractUpdated("Terminate");
    }

    function ReadyToTransport() public {
        if (Price == 0) {
            revert();
        }
        if (State != StateType.Created) {
            revert();
        }

        Provider = msg.sender;        
        ProviderBalance = ProviderBalance - Price;
        FarmerBalance = Price;          

        State = StateType.ReadyToTransport;
        ContractUpdated("ReadyToTransport");
    }

    function OnTheWay(uint humidity, int temperature) public {      

        Seller = msg.sender;
        Price = (Price * 13)/10;

        if (State != StateType.ReadyToTransport) {
            revert();
        }        

        if (humidity > MaxHumidity || humidity < MinHumidity || temperature > MaxTemperature || temperature < MinTemperature) {            
            
            ComplianceStatus = false;
        }

        if (ComplianceStatus == false) {
            State = StateType.Cancelled;
        }

        State = StateType.InTransit;
        ContractUpdated("OnTheWay");
    }

    function Delivered() public {     
        if (State == StateType.Cancelled) {
            revert();
        }        
        SellerBalance = SellerBalance - Price; 
        ProviderBalance = ProviderBalance + Price;

        State = StateType.Delivered;
        ContractUpdated("Delivered");
    }

    function Available() public {
        if (State == StateType.Cancelled) {
            revert();
        }             
        Price = (Price * 11)/10;  
        if (State == StateType.Delivered) {
            State = StateType.Available;        
        }
        ContractUpdated("Available");
    }    

    function Cancelled() public {     
        Seller = msg.sender;
        uint penalty = Price / 10;  
        SellerBalance = SellerBalance + penalty; 
        ProviderBalance = ProviderBalance - penalty;    
        State = StateType.Cancelled;           
        
        ContractUpdated("Cancelled");
    }    

    function Selled() public {    
        if (State == StateType.Cancelled) {
            revert();
        }           
        Buyer = msg.sender;
        BuyerBalance = BuyerBalance - Price; 
        SellerBalance = SellerBalance + Price; 
        if (State == StateType.Available) {
            State = StateType.Selled;        
        }
        ContractUpdated("Selled");
    }    

}