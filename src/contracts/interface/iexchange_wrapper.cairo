use starknet::ContractAddress;

#[starknet::interface]
pub trait iexchange_wrapper<TContractState> {
    fn swap_input(ref self: TContractState, inputToken: ContractAddress, outputToken: ContractAddress, inputTokenSold: u256, minOutputTokenBought: u256, maxPrice: u256) -> u256;
    fn swap_output(ref self: TContractState, inputToken: ContractAddress, outputToken: ContractAddress, outputTokenBought: u256, minInputTokenSold: u256, maxPrice: u256) -> u256;
    fn get_input_price(self: @TContractState, inputToken: ContractAddress, outputToken: ContractAddress, inputTokenSold: u256) -> u256;
    fn get_output_price(self: @TContractState, inputToken: ContractAddress, outputToken: ContractAddress, outputTokenBought: u256);
    fn get_spot_price(self: @TContractState, inputToken: ContractAddress, outputToken: ContractAddress) -> u256;
}