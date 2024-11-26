#[starknet::contract]
pub mod block_context{
    use core::box::BoxTrait;
    use starknet::get_block_timestamp;
    use starknet::get_block_info;

    #[storage]
    struct Storage {}


    pub fn block_timestamp() -> u64{
        return get_block_timestamp();
    }

    pub fn block_number() -> u64{
        return get_block_info().unbox().block_number;
    }

}