use starknet::ContractAddress;

#[starknet::interface]
pub trait iinsurance_fund<TContractState> {
    fn withdraw(ref self: TContractState, _quoteToken: ContractAddress, _amount: u256);
    fn is_existed_amm(self: @TContractState, _amm: ContractAddress) -> bool;
    fn get_all_amms(self: @TContractState) -> ((u256, ContractAddress), u256);
}