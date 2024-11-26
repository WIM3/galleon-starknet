use starknet::ContractAddress;

#[derive(Serde, Copy, Drop)]
struct Position{
    size: i128,
    margin: u256,
    openNotional: u256,
    lastUpdatedCumulativePremiumFraction: i128,
    liquidityHistoryIndex: u256,
    blockNumber: u256,
}

#[starknet::interface]
pub trait iclearing_house<TContractState> {
    fn add_margin(ref self: TContractState, _amm: ContractAddress, _addedMargin: u256);
    fn remove_margin(ref self: TContractState,  _amm: ContractAddress, _removedMargin: u256);
    fn settle_position(ref self: TContractState,  _amm: ContractAddress);
    fn open_position(ref self: TContractState,  _amm: ContractAddress, _side: u8, _quoteAssetAmount: u256, _leverage: u8, _baseAssetAmountLimit: u256);
    fn close_position(ref self: TContractState,  _amm: ContractAddress, _quoteAssetAmountLimit: u256);
    fn liquidate(ref self: TContractState,  _amm: ContractAddress, _trader: ContractAddress);
    fn pay_funding(ref self: TContractState,  _amm: ContractAddress);
    // VIEW FUNCTIONS
    fn get_margin_ratio(self: @TContractState,  _amm: ContractAddress, _trader: ContractAddress) -> i128;
    fn get_position(self: @TContractState,  _amm: ContractAddress, _trader: ContractAddress) -> Position;
}