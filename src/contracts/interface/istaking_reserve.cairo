use starknet::{ContractAddress};

#[derive(Drop, Copy, Serde)]
struct FeeBalance {
    token: ContractAddress,
    balance: u256
}

#[derive(Drop, Copy, Serde)]
struct LockedBalance {
    exist: bool,
    locked: u256,
    timeWeightedLocked: u256,
}

#[starknet::interface]
pub trait istaking_reserve<TContractState> {
    fn setVestingPeriod(ref self: TContractState, _vestingPeriod: u256);
    fn stake(ref self: TContractState, _amount: u256);
    fn unstake(ref self: TContractState, _amount: u256);
    fn depositAndStake(ref self: TContractState ,_amount: u256);
    fn withdraw(ref self: TContractState,_amount: u256);
    fn notifyRewardAmount(ref self: TContractState, _amount: u256);
    fn notifyTokenAmount(ref self: TContractState ,_token: ContractAddress, _amount: u256);
    fn claimFeesAndVestedReward(ref self: TContractState);
    fn setFeeNotifier(ref self: TContractState ,_notifier: ContractAddress);
    fn isExistedFeeToken(self: @TContractState, _token: ContractAddress) -> bool;
    fn nextEpochIndex(self: @TContractState) -> u256;
    fn getTotalBalance(self: @TContractState) -> u256;
    fn getTotalEffectiveStake(self: @TContractState, _epochIndex: u256) -> u256;
    fn getFeeOfEpoch(self: @TContractState, _epoch: u256, _token: ContractAddress) -> u256;
    fn getFeeRevenue(self: @TContractState ,_staker: ContractAddress) -> Array<FeeBalance>;
    fn getVestedReward(self: @TContractState, _staker: ContractAddress) -> u256;
    fn getUnlockedBalance(self: @TContractState ,_staker: ContractAddress) -> u256;
    fn getUnstakableBalance(self: @TContractState, _staker: ContractAddress) -> u256;
    fn getLockedBalance(self: @TContractState, _staker: ContractAddress, _epochIndex: u256) -> LockedBalance;
    fn getEpochRewardHistoryLength(self: @TContractState) -> u256;
    fn getRewardEpochCursor(self: @TContractState ,_staker: ContractAddress) -> u256;
    fn getFeeEpochCursor(self: @TContractState, _staker: ContractAddress) -> u256;
}