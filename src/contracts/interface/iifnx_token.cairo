use starknet::ContractAddress;

#[starknet::interface]
pub trait iifnx_token<TContractState> {
    fn mint(ref self: TContractState, account: ContractAddress, amount: u256);
}