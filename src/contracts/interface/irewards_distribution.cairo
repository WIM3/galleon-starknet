use starknet::ContractAddress;

#[starknet::interface]
pub trait irewards_distribution<TContractState> {
    fn distribute_rewards(ref self: TContractState, _ifnxToken: ContractAddress, _amount: u256);
    fn add_rewards_distribution(ref self: TContractState, _destination: ContractAddress, _amount: u256);
    fn remove_rewards_distribution(ref self: TContractState, _index: u256);
    fn edit_rewards_distribution(ref self: TContractState, _index: u256, _destination: ContractAddress, _amount: u256);
}