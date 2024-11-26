use starknet::ContractAddress;

#[starknet::interface]
pub trait iminter<TContractState> {
    fn mint_reward(ref self: TContractState);
    fn mint_for_loss(ref self: TContractState, _amount: u256);
    fn get_ifnx_token(self: @TContractState) -> ContractAddress;
    fn set_insurance_fund(ref self: TContractState, _insuranceFund: ContractAddress);
    fn set_rewards_distribution(ref self: TContractState, _rewardsDistribution: ContractAddress);
    fn set_supply_schedule(ref self: TContractState, _supplySchedule: ContractAddress);
    fn set_inflation_monitor(ref self: TContractState, _inflationMonitor: ContractAddress);
}