pub(crate) mod contracts{
    pub(crate) mod clearing_house;
    pub(crate) mod insurance_fund;
    pub(crate) mod supply_schedule;
    pub(crate) mod minter;
    pub(crate) mod rewards_distribution;
    pub(crate) mod staking_reserve;
    pub(crate) mod interface{
        pub(crate) mod ierc20;
        pub(crate) mod iamm;
        pub(crate) mod iclearing_house;
        pub(crate) mod iexchange_wrapper;
        pub(crate) mod iifnx_token;
        pub(crate) mod iinflation_monitor;
        pub(crate) mod iinsurance_fund;
        pub(crate) mod iminter;
        pub(crate) mod imulti_token_reward_recipient;
        pub(crate) mod iprice_feed;
        pub(crate) mod ireward_recipient;
        pub(crate) mod irewards_distribution;
        pub(crate) mod istake_module;
        pub(crate) mod isupply_schedule;
        pub(crate) mod istaking_reserve;
    }
    pub(crate) mod utils{
        pub(crate) mod decimal_math;
        pub(crate) mod decimal;
        pub(crate) mod block_context;
        pub(crate) mod ifnx_fi_ownable_upgrade;
    }
}