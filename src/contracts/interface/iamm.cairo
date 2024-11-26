use starknet::ContractAddress;

#[derive(Drop, Copy, Serde)]
struct LiquidityChangedSnapshot{
    cumulativeNotional: i128,
    // the base/quote reserve of amm right before liquidity changed
    quoteAssetReserve: u256,
    baseAssetReserve: u256,
    // total position size owned by amm after last snapshot taken
    // `totalPositionSize` = currentBaseAssetReserve - lastLiquidityChangedHistoryItem.baseAssetReserve + prevTotalPositionSize
    totalPositionSize: i128
}

#[starknet::interface]
pub trait iamm<TContractState> {
    fn swap_input(ref self: TContractState, _dir: u8, _quoteAssetAmount: u256, _baseAssetAmount: u256, _canOverFluctuationLimit: bool) -> u256;
    fn swap_output(ref self: TContractState, _dir: u8, _baseAssetAmount: u256, _quoteAssetAmount: u256) -> u256;
    fn shutdown(ref self: TContractState);
    fn settle_funding(ref self: TContractState) -> i128;
    fn calc_fee(self: @TContractState, _quoteAssetAmount: u256) -> u256;

    //
    // VIEW
    //

    fn is_over_fluctuation_limit(self: @TContractState, _dirOfBase: u8, _baseAssetAmount: u256) -> bool;
    fn calc_base_asset_after_liquidity_migration(self: @TContractState, _baseAssetAmount: u256, _fromQuoteReserve: u256, _fromBaseReserve: u256) -> i128;
    fn get_input_twap(self: @TContractState, _dir: u8, _quoteAssetAmount: u256) -> u256;
    fn get_output_twap(self: @TContractState, _dir: u8, _baseAssetAmount: u256) -> u256;
    fn get_input_price(self: @TContractState, _dir: u8, _quoteAssetAmount: u256) -> u256;
    fn get_output_price(self: @TContractState, _dir: u8, _baseAssetAmount: u256) -> u256;
    fn get_input_price_with_reserves(self: @TContractState, _dir: u8, _quoteAssetAmount: u256, _quoteAssetPoolAmount: u256, _baseAssetPoolAmount: u256) -> u256;
    fn get_output_price_with_reserves(self: @TContractState, _dir: u8, _baseAssetAmount: u256, _quoteAssetPoolAmount: u256, _baseAssetPoolAmount: u256) -> u256;
    fn get_spot_price(self: @TContractState) -> u256;
    fn get_liquidity_history_length(self: @TContractState) -> u256;
    fn quote_asset(self: @TContractState) -> ContractAddress;
    fn open(self: @TContractState) -> bool;
    fn get_settlement_price(self: @TContractState) -> u256;
    fn get_base_asset_delta_this_funding_period(self: @TContractState) -> i128;
    fn get_cumulative_notional(self: @TContractState) -> i128;
    fn get_max_holding_base_asset(self: @TContractState) -> u256;
    fn get_open_inrest_notional_cap(self: @TContractState) -> u256;
    fn get_liquidity_changed_snapshots(self: @TContractState, i: u256) -> LiquidityChangedSnapshot;
    fn get_base_asset_delta(self: @TContractState) -> i128;
    fn get_underlyingPrice(self: @TContractState) -> u256;    
    fn is_over_spread_limit(self: @TContractState) -> bool;

}