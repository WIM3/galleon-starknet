use starknet::ContractAddress;

#[starknet::interface]
pub trait istake_module<TContractState> {
    fn notify_stake_changed(ref self: TContractState, staker: ContractAddress);
}