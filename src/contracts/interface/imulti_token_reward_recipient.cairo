use starknet::ContractAddress;

#[starknet::interface]
pub trait imulti_token_reward_recipient<TContractState> {
    fn notify_token_amount(ref self: TContractState, _token: ContractAddress, _amount: u256);
}