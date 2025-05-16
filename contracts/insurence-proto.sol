// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

/**
 * @title InsuranceProtocol
 * @dev A decentralized insurance protocol that allows users to create insurance pools,
 * contribute premiums, and file claims that are automatically processed based on predefined conditions.
 */
contract InsuranceProtocol {
    struct InsurancePool {
        address creator;
        string coverageType;
        uint256 totalFunds;
        uint256 premiumAmount;
        uint256 maxCoverage;
        uint256 claimThreshold;
        bool active;
        mapping(address => uint256) contributions;
        mapping(address => bool) insured;
    }

    struct Claim {
        address claimant;
        uint256 poolId;
        uint256 amount;
        string description;
        bool processed;
        bool approved;
    }

    uint256 private poolCounter;
    mapping(uint256 => InsurancePool) public insurancePools;
    mapping(uint256 => Claim[]) public claims;
    
    // Events
    event PoolCreated(uint256 indexed poolId, address indexed creator, string coverageType);
    event PremiumPaid(uint256 indexed poolId, address indexed contributor, uint256 amount);
    event ClaimFiled(uint256 indexed poolId, address indexed claimant, uint256 claimId, uint256 amount);
    event ClaimProcessed(uint256 indexed poolId, uint256 indexed claimId, bool approved, uint256 amount);
    
    /**
     * @dev Creates a new insurance pool
     * @param _coverageType The type of insurance coverage offered
     * @param _premiumAmount The required premium amount to join the pool
     * @param _maxCoverage The maximum coverage amount per insured member
     * @param _claimThreshold The minimum amount for valid claims
     */
    function createInsurancePool(
        string memory _coverageType,
        uint256 _premiumAmount,
        uint256 _maxCoverage,
        uint256 _claimThreshold
    ) external {
        require(_premiumAmount > 0, "Premium amount must be greater than 0");
        require(_maxCoverage > _premiumAmount, "Max coverage must exceed premium");
        
        uint256 poolId = poolCounter++;
        
        InsurancePool storage newPool = insurancePools[poolId];
        newPool.creator = msg.sender;
        newPool.coverageType = _coverageType;
        newPool.premiumAmount = _premiumAmount;
        newPool.maxCoverage = _maxCoverage;
        newPool.claimThreshold = _claimThreshold;
        newPool.active = true;
        
        emit PoolCreated(poolId, msg.sender, _coverageType);
    }
    
    /**
     * @dev Allows users to pay premiums and join an insurance pool
     * @param _poolId The ID of the insurance pool to join
     */
    function payPremium(uint256 _poolId) external payable {
        InsurancePool storage pool = insurancePools[_poolId];
        
        require(pool.active, "Insurance pool is not active");
        require(msg.value == pool.premiumAmount, "Must pay exact premium amount");
        require(!pool.insured[msg.sender], "Already insured in this pool");
        
        pool.totalFunds += msg.value;
        pool.contributions[msg.sender] += msg.value;
        pool.insured[msg.sender] = true;
        
        emit PremiumPaid(_poolId, msg.sender, msg.value);
    }
    
    /**
     * @dev Allows insured members to file an insurance claim
     * @param _poolId The ID of the insurance pool
     * @param _amount The amount being claimed
     * @param _description Description of the claim
     * @return claimId The ID of the newly created claim
     */
    function fileClaim(
        uint256 _poolId,
        uint256 _amount,
        string memory _description
    ) external returns (uint256) {
        InsurancePool storage pool = insurancePools[_poolId];
        
        require(pool.active, "Insurance pool is not active");
        require(pool.insured[msg.sender], "Not insured in this pool");
        require(_amount >= pool.claimThreshold, "Claim amount below threshold");
        require(_amount <= pool.maxCoverage, "Claim exceeds maximum coverage");
        
        uint256 claimId = claims[_poolId].length;
        
        claims[_poolId].push(Claim({
            claimant: msg.sender,
            poolId: _poolId,
            amount: _amount,
            description: _description,
            processed: false,
            approved: false
        }));
        
        emit ClaimFiled(_poolId, msg.sender, claimId, _amount);
        return claimId;
    }
}
