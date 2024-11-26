use starknet::ContractAddress;

#[starknet::interface]
pub trait iinflation_monitor<TContractState> {
    fn is_over_mint_threshold(self: @TContractState) -> bool;

    fn append_minted_token_history(ref self: TContractState, _amount: u256);
}