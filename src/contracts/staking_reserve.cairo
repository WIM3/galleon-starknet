use galleon_starknet::contracts::interface::istaking_reserve::istaking_reserve;
#[starknet::contract]
pub mod staking_reserve{
    use galleon_starknet::contracts::interface::isupply_schedule::isupply_scheduleDispatcherTrait;
use starknet::{ContractAddress};
    use galleon_starknet::contracts::interface::istaking_reserve::{istaking_reserve};
    use galleon_starknet::contracts::interface::isupply_schedule::{isupply_scheduleDispatcher};
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::get_block_timestamp;
    use starknet::get_block_info;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        RewardWithdrawn: RewardWithdrawn,
        FeeInEpoch: FeeInEpoch
    }

    #[derive(Drop, starknet::Event)]
    struct RewardWithdrawn{
        staker: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct FeeInEpoch{
        token: ContractAddress,
        fee: u256,
        epoch: u256
    }

    #[derive(Drop, Copy, Serde)]
    struct EpochReward {
        perpReward: u256,
        feeMap: LegacyMap::<ContractAddress, u256>
    }

    #[derive(Drop, Copy, Serde)]
    struct StakeBalance {
        exist: bool,
        totalBalance: u256,
        rewardEpochCursor: u256,
        feeEpochCursor: u256,
        lockedBalanceMap: LegacyMap::<u256, LockedBalance>
    }

    #[derive(Drop, Copy, Serde)]
    struct LockedBalance {
        exist: bool,
        locked: u256,
        timeWeightedLocked: u256,
    }

    #[derive(Drop, Copy, Serde)]
    struct FeeBalance {
        token: ContractAddress,
        balance: u256
    }

    #[storage]
    struct Storage {
        owner: ContractAddress,
        candidate: ContractAddress,
        totalPendingStakeBalance: i128,
        vestingPeriod: u256,
        stakeBalanceMap: LegacyMap::<ContractAddress, StakeBalance>,
        totalEffectiveStakeMap: LegacyMap::<u256, u256>,
        epochRewardHistory: Array<EpochReward>,
        stakers: Array<ContractAddress>,
        ifnxToken: ContractAddress,
        supplySchedule: ContractAddress,
        feeTokens: Array<ContractAddress>,
        feeMap: LegacyMap::<ContractAddress, u256>,
        feeNotifier: ContractAddress,
        token: ContractAddress,
    }

    fn constructor(
        ref self: ContractState,
        _ifnxToken: ContractAddress,
        _supplySchedule: ContractAddress,
        _feeNotifier: ContractAddress,
        _vestingPeriod: u256,
    ) {
        ownable_init(ref self);
        self.ifnxToken.write(_ifnxToken);
        self.supplySchedule.write(_supplySchedule);
        self.feeNotifier.write(_feeNotifier);
        self.vestingPeriod.write(_vestingPeriod);
    }

    #[abi(embed_v0)]
    impl staking_reward of istaking_reserve<ContractState> {
        fn setVestingPeriod(ref self: TContractState, _vestingPeriod: u256){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.vestingPeriod.write(_vestingPeriod);
        }
        fn stake(ref self: TContractState, _amount: u256){
            assert!(_amount > 0, "Input amount is zero");
            let sender = get_caller_address();
            assert!(_amount <= self.getUnlockedBalance(sender), "Stake more than all balance");
            let sc = isupply_scheduleDispatcher{contract_address: self.supplySchedule.read()};
            assert!(sc.is_started(), "IFNX reward has not started");
            let epochDuration = sc.mint_duration();
            let afterNextEpochIndex = self.nextEpochIndex() + 1;
            let nextEndEpochTimestamp = sc.next_mint_time();
            let mut timeWeightedLocked: u256 = 0;
            if(nextEndEpochTimestamp > get_block_timestamp()){
                
            }
        }   
        function stake(Decimal.decimal memory _amount) public {
            if (nextEndEpochTimestamp > _blockTimestamp()) {
                // calculate timeWeightedLocked based on additional staking amount and the remain time during this epoch
                timeWeightedLocked = _amount
                    .mulScalar(nextEndEpochTimestamp.sub(_blockTimestamp()))
                    .divScalar(epochDuration);
    
                // update stakerBalance for next epoch
                increaseStake(sender, nextEpochIndex(), _amount, timeWeightedLocked);
            }
    
            // update stakerBalance for next + 1 epoch
            StakeBalance storage balance = stakeBalanceMap[sender];
            if (balance.lockedBalanceMap[afterNextEpochIndex].exist) {
                increaseStake(sender, afterNextEpochIndex, _amount, _amount);
            } else {
                LockedBalance memory currentBalance = balance.lockedBalanceMap[nextEpochIndex()];
                balance.lockedBalanceMap[afterNextEpochIndex] = LockedBalance(
                    true,
                    currentBalance.locked,
                    currentBalance.locked
                );
            }
    
            // update global stake balance states
            totalEffectiveStakeMap[nextEpochIndex()] = totalEffectiveStakeMap[nextEpochIndex()].addD(
                timeWeightedLocked
            );
            totalPendingStakeBalance = totalPendingStakeBalance.addD(_amount).subD(timeWeightedLocked);
        }
    
        fn unstake(ref self: TContractState, _amount: u256){}
        fn depositAndStake(ref self: TContractState ,_amount: u256){}
        fn withdraw(ref self: TContractState,_amount: u256){}
        fn notifyRewardAmount(ref self: TContractState, _amount: u256){}
        fn notifyTokenAmount(ref self: TContractState ,_token: ContractAddress, _amount: u256){}
        fn claimFeesAndVestedReward(ref self: TContractState){}
        fn setFeeNotifier(ref self: TContractState ,_notifier: ContractAddress){}
        fn isExistedFeeToken(self: @TContractState, _token: ContractAddress) -> bool{}
        fn nextEpochIndex(self: @TContractState) -> u256{
            return self.epochRewardHistory.read().len();
        }
        fn getTotalBalance(self: @TContractState) -> u256{}
        fn getTotalEffectiveStake(self: @TContractState, _epochIndex: u256) -> u256{}
        fn getFeeOfEpoch(self: @TContractState, _epoch: u256, _token: ContractAddress) -> u256{}
        fn getFeeRevenue(self: @TContractState ,_staker: ContractAddress) -> Array<FeeBalance>{}
        fn getVestedReward(self: @TContractState, _staker: ContractAddress) -> u256{}
        fn getUnlockedBalance(self: @TContractState ,_staker: ContractAddress) -> u256{
            let lockedForNextEpoch = self.getLockedBalance(_staker, self.nextEpochIndex()).locked;
            return self.stakeBalanceMap.read(_staker).totalBalance - lockedForNextEpoch;
        }
        fn getUnstakableBalance(self: @TContractState, _staker: ContractAddress) -> u256{}
        fn getLockedBalance(self: @TContractState, _staker: ContractAddress, _epochIndex: u256) -> LockedBalance{
            let mut ei = _epochIndex;
            while ei >= 0 {
                let lockedBalance: LockedBalance = self.stakeBalanceMap.read(_staker).lockedBalanceMap.read(_epochIndex);
                if(lockedBalance.exist) {
                    return lockedBalance;
                }
                if(ei == 0){
                    break;
                }
                ei -= 1;
            }
            return LockedBalance{exist: false, locked: 0, timeWeightedLocked: 0};
        }
     
        fn getEpochRewardHistoryLength(self: @TContractState) -> u256{}
        fn getRewardEpochCursor(self: @TContractState ,_staker: ContractAddress) -> u256{}
        fn getFeeEpochCursor(self: @TContractState, _staker: ContractAddress) -> u256{}
    }


    /**
     * @dev staker can decrease staking from stakeBalanceForNextEpoch
     */
    function unstake(Decimal.decimal calldata _amount) external {
        require(_amount.toUint() > 0, "Input amount is zero");
        address sender = _msgSender();
        require(
            _amount.toUint() <= getUnstakableBalance(sender).toUint(),
            "Unstake more than locked balance"
        );

        // decrease stake balance for after next epoch
        uint256 afterNextEpochIndex = nextEpochIndex().add(1);
        LockedBalance memory afterNextLockedBalance = getLockedBalance(sender, afterNextEpochIndex);
        stakeBalanceMap[sender].lockedBalanceMap[afterNextEpochIndex] = LockedBalance(
            true,
            afterNextLockedBalance.locked.subD(_amount),
            afterNextLockedBalance.timeWeightedLocked.subD(_amount)
        );

        // update global stake balance states
        totalPendingStakeBalance = totalPendingStakeBalance.subD(_amount);
    }

    function depositAndStake(Decimal.decimal calldata _amount) external nonReentrant {
        deposit(_msgSender(), _amount);
        stake(_amount);
    }

    function withdraw(Decimal.decimal calldata _amount) external nonReentrant {
        require(_amount.toUint() != 0, "Input amount is zero");
        address sender = _msgSender();
        require(_amount.toUint() <= getUnlockedBalance(sender).toUint(), "Not enough balance");
        stakeBalanceMap[sender].totalBalance = stakeBalanceMap[sender].totalBalance.subD(_amount);
        _transfer(IERC20(ifnxToken), sender, _amount);
    }

    /**
     * @dev add epoch reward, update totalEffectiveStakeMap
     */
    function notifyRewardAmount(Decimal.decimal calldata _amount)
        external
        override
        onlyRewardsDistribution
    {
        // record reward to epochRewardHistory
        Decimal.decimal memory totalBalanceBeforeEndEpoch = getTotalBalance();
        epochRewardHistory.push(EpochReward(_amount));

        // Note this is initialized AFTER a new entry is pushed to epochRewardHistory, hence the minus 1
        uint256 currentEpochIndex = nextEpochIndex().sub(1);
        for (uint256 i; i < feeTokens.length; i++) {
            IERC20 token = feeTokens[i];
            emit FeeInEpoch(address(token), feeMap[token].toUint(), currentEpochIndex);
            epochRewardHistory[currentEpochIndex].feeMap[address(token)] = feeMap[token];
            feeMap[token] = Decimal.zero();
        }

        // update totalEffectiveStakeMap for coming epoch
        SignedDecimal.signedDecimal
            memory updatedTotalEffectiveStakeBalance = totalPendingStakeBalance.addD(
                totalBalanceBeforeEndEpoch
            );
        require(updatedTotalEffectiveStakeBalance.toInt() >= 0, "Unstake more than locked balance");
        totalEffectiveStakeMap[(nextEpochIndex())] = updatedTotalEffectiveStakeBalance.abs();
        totalPendingStakeBalance = SignedDecimal.zero();
    }

    function notifyTokenAmount(IERC20 _token, Decimal.decimal calldata _amount) external override {
        require(feeNotifier == _msgSender(), "!feeNotifier");
        require(_amount.toUint() > 0, "amount can't be 0");

        feeMap[_token] = feeMap[_token].addD(_amount);
        if (!isExistedFeeToken(_token)) {
            feeTokens.push(_token);
        }
    }

    /*
     * claim all fees and vested reward at once
     * update lastUpdatedEffectiveStake
     */
    function claimFeesAndVestedReward() external nonReentrant {
        // calculate fee and reward
        address staker = _msgSender();
        Decimal.decimal memory reward = getVestedReward(staker);
        FeeBalance[] memory fees = getFeeRevenue(staker);
        bool hasFees = fees.length > 0;
        bool hasReward = reward.toUint() > 0;
        require(hasReward || hasFees, "no vested reward or fee");

        // transfer fee reward
        stakeBalanceMap[staker].feeEpochCursor = epochRewardHistory.length;
        for (uint256 i = 0; i < fees.length; i++) {
            if (fees[i].balance.toUint() != 0) {
                _transfer(IERC20(fees[i].token), staker, fees[i].balance);
            }
        }

        // transfer perp reward
        if (hasReward && epochRewardHistory.length >= vestingPeriod) {
            // solhint-disable reentrancy
            stakeBalanceMap[staker].rewardEpochCursor = epochRewardHistory.length.sub(
                vestingPeriod
            );
            _transfer(IERC20(ifnxToken), staker, reward);
            emit RewardWithdrawn(staker, reward.toUint());
        }
    }

    function setFeeNotifier(address _notifier) external onlyOwner {
        feeNotifier = _notifier;
    }

    //
    // VIEW FUNCTIONS
    //

    function isExistedFeeToken(IERC20 _token) public view returns (bool) {
        for (uint256 i = 0; i < feeTokens.length; i++) {
            if (feeTokens[i] == _token) {
                return true;
            }
        }
        return false;
    }

    function nextEpochIndex() public view returns (uint256) {
        return epochRewardHistory.length;
    }

    /**
     * everyone can query total balance to check current collateralization ratio.
     * TotalBalance of time weighted locked IFNX for coming epoch
     */
    function getTotalBalance() public view returns (Decimal.decimal memory) {
        return totalEffectiveStakeMap[nextEpochIndex()];
    }

    function getTotalEffectiveStake(uint256 _epochIndex)
        public
        view
        returns (Decimal.decimal memory)
    {
        return totalEffectiveStakeMap[_epochIndex];
    }

    function getFeeOfEpoch(uint256 _epoch, address _token)
        public
        view
        returns (Decimal.decimal memory)
    {
        return epochRewardHistory[_epoch].feeMap[_token];
    }

    function getFeeRevenue(address _staker) public view returns (FeeBalance[] memory feeBalance) {
        StakeBalance storage balance = stakeBalanceMap[_staker];
        if (balance.feeEpochCursor == nextEpochIndex()) {
            return feeBalance;
        }

        uint256 numberOfTokens = feeTokens.length;
        feeBalance = new FeeBalance[](numberOfTokens);
        Decimal.decimal memory latestLockedStake;
        // TODO enhancement, we can loop feeTokens first to save more gas if some feeToken was not used
        for (uint256 i = balance.feeEpochCursor; i < nextEpochIndex(); i++) {
            if (balance.lockedBalanceMap[i].timeWeightedLocked.toUint() != 0) {
                latestLockedStake = balance.lockedBalanceMap[i].timeWeightedLocked;
            }
            if (latestLockedStake.toUint() == 0) {
                continue;
            }
            Decimal.decimal memory effectiveStakePercentage = latestLockedStake.divD(
                totalEffectiveStakeMap[i]
            );

            for (uint256 j = 0; j < numberOfTokens; j++) {
                IERC20 token = feeTokens[j];
                Decimal.decimal memory feeInThisEpoch = getFeeOfEpoch(i, address(token));
                if (feeInThisEpoch.toUint() == 0) {
                    continue;
                }
                feeBalance[j].balance = feeBalance[j].balance.addD(
                    feeInThisEpoch.mulD(effectiveStakePercentage)
                );
                feeBalance[j].token = address(token);
            }
        }
    }

    function getVestedReward(address _staker) public view returns (Decimal.decimal memory reward) {
        if (nextEpochIndex() < vestingPeriod) {
            return Decimal.zero();
        }

        // Note that rewardableEpochEnd is exclusive. The last rewardable epoch index = rewardableEpochEnd - 1
        uint256 rewardableEpochEnd = nextEpochIndex().sub(vestingPeriod);
        StakeBalance storage balance = stakeBalanceMap[_staker];
        if (balance.rewardEpochCursor > rewardableEpochEnd) {
            return Decimal.zero();
        }

        Decimal.decimal memory latestLockedStake;
        for (uint256 i = balance.rewardEpochCursor; i < rewardableEpochEnd; i++) {
            if (balance.lockedBalanceMap[i].timeWeightedLocked.toUint() != 0) {
                latestLockedStake = balance.lockedBalanceMap[i].timeWeightedLocked;
            }
            if (latestLockedStake.toUint() == 0) {
                continue;
            }
            Decimal.decimal memory rewardInThisEpoch = epochRewardHistory[i]
                .perpReward
                .mulD(latestLockedStake)
                .divD(totalEffectiveStakeMap[i]);
            reward = reward.addD(rewardInThisEpoch);
        }
    }

    

    // unstakable = lockedBalance@NextEpoch+1
    function getUnstakableBalance(address _staker) public view returns (Decimal.decimal memory) {
        return getLockedBalance(_staker, nextEpochIndex().add(1)).locked;
    }

    // only store locked balance when there's changed, so if the target lockedBalance is not exist,
    // use the lockedBalance from the closest previous epoch
    

    function getEpochRewardHistoryLength() external view returns (uint256) {
        return epochRewardHistory.length;
    }

    function getRewardEpochCursor(address _staker) public view returns (uint256) {
        return stakeBalanceMap[_staker].rewardEpochCursor;
    }

    function getFeeEpochCursor(address _staker) public view returns (uint256) {
        return stakeBalanceMap[_staker].feeEpochCursor;
    }

    //
    // Private
    //

    function increaseStake(
        address _sender,
        uint256 _epochIndex,
        Decimal.decimal memory _locked,
        Decimal.decimal memory _timeWeightedLocked
    ) private {
        LockedBalance memory lockedBalance = getLockedBalance(_sender, _epochIndex);
        stakeBalanceMap[_sender].lockedBalanceMap[_epochIndex] = LockedBalance(
            true,
            lockedBalance.locked.addD(_locked),
            lockedBalance.timeWeightedLocked.addD(_timeWeightedLocked)
        );
    }

    function deposit(address _sender, Decimal.decimal memory _amount) private {
        require(_amount.toUint() != 0, "Input amount is zero");
        StakeBalance storage balance = stakeBalanceMap[_sender];
        if (!balance.exist) {
            stakers.push(_sender);
            balance.exist = true;
            // set rewardEpochCursor for the first staking
            balance.rewardEpochCursor = nextEpochIndex();
        }
        balance.totalBalance = balance.totalBalance.addD(_amount);
        _transferFrom(IERC20(ifnxToken), _sender, address(this), _amount);
    }
}