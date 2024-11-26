use starknet::ContractAddress;

#[starknet::interface]
pub trait ireward_recipient<TContractState> {
    fn notify_reward_amount(ref self: TContractState, _amount: u256);
    fn token(self: @TContractState) -> ContractAddress;
}