#[starknet::contract]
pub mod supply_schedule{
    use galleon_starknet::contracts::interface::ierc20::ierc20DispatcherTrait;
    use galleon_starknet::contracts::interface::iminter::iminterDispatcherTrait;
    use core::traits::Into;
    use core::traits::TryInto;
    use starknet::{ContractAddress};
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use galleon_starknet::contracts::interface::isupply_schedule::{isupply_schedule};
    use starknet::get_block_timestamp;
    use starknet::get_block_info;
    use alexandria_math::pow;
    use galleon_starknet::contracts::interface::iminter::{iminterDispatcher};
    use galleon_starknet::contracts::interface::ierc20::{ierc20Dispatcher};
    
    
    const SUPPLY_DECAY_PERIOD: u256 = 126403200;

    // Percentage growth of terminal supply per annum
    const TERMINAL_SUPPLY_EPOCH_RATE: u256 = 474970697307300; // 2.5% annual ~= 0.04749% weekly

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred{
        previousOwner: ContractAddress,
        newOwner: ContractAddress
    }


    #[storage]
    struct Storage {
        owner: ContractAddress,
        candidate: ContractAddress,
        inflationRate: u256,
        decayRate: u256,
        mintDuration: u256, // default is 1 week
        nextMintTime: u256,
        supplyDecayEndTime: u256, // startSchedule time + 4 years
        minter: ContractAddress
    }

    #[constructor]
    fn constructor(
        ref self: ContractState,
        _minter: ContractAddress,
        _inflationRate: u256,
        _decayRate: u256,
        _mintDuration: u256
    ) {
        ownable_init(ref self);
        self.minter.write(_minter);
        self.inflationRate.write(_inflationRate);
        self.decayRate.write(_decayRate);
        self.mintDuration.write(_mintDuration);
    }

    fn ownable_init(ref self: ContractState){
        let mut msgSender: ContractAddress = get_caller_address();
        self.owner.write(msgSender);
        self.emit(OwnershipTransferred{previousOwner: contract_address_const::<0>(), newOwner: msgSender});    
    }

    fn ownable_init_unchained(ref self: ContractState) {
        let mut msgSender: ContractAddress = get_caller_address();
        self.owner.write(msgSender);
        self.emit(OwnershipTransferred{previousOwner: contract_address_const::<0>(), newOwner: msgSender});
    }
    fn owner(self: @ContractState) -> ContractAddress{
        return self.owner.read();
    }
    fn candidate(self: @ContractState) -> ContractAddress{
        return self.candidate.read();
    }
    fn renounceOwnership(ref self: ContractState){
        assert!(self.owner.read() == get_caller_address(), "IfnxFiOwnableUpgrade: caller is not the owner");
        self.emit(OwnershipTransferred{previousOwner: self.owner.read(), newOwner: contract_address_const::<0>()});
        self.owner.write(contract_address_const::<0>());    
    }
    fn set_owner(ref self: ContractState, newOwner: ContractAddress){
        assert!(self.owner.read() == get_caller_address(), "IfnxFiOwnableUpgrade: caller is not the owner");
        assert!(newOwner != contract_address_const::<0>(), "IfnxFiOwnableUpgrade: zero address");
        assert!(newOwner != self.owner.read(), "IfnxFiOwnableUpgrade: same as original");
        assert!(newOwner != self.candidate.read(), "IfnxFiOwnableUpgrade: same as candidate");
        self.candidate.write(newOwner);
    }
    fn update_owner(ref self: ContractState){
        assert!(self.candidate.read() != contract_address_const::<0>(), "IfnxFiOwnableUpgrade: candidate is zero address");
        assert!(self.candidate.read() == get_caller_address(), "IfnxFiOwnableUpgrade: not the new owner");
        self.emit(OwnershipTransferred{previousOwner: self.owner.read(), newOwner: self.candidate.read()});
        self.owner.write(self.candidate.read());
        self.candidate.write(contract_address_const::<0>());
    }

    #[abi(embed_v0)]
    impl supply_schedule of isupply_schedule<ContractState> {
        fn start_schedule(ref self: ContractState){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            assert!(self.mintDuration.read() > 0, "mint duration is 0");
            self.nextMintTime.write(get_block_timestamp().into() + self.mintDuration.read());
            self.supplyDecayEndTime.write(get_block_timestamp().into() + SUPPLY_DECAY_PERIOD);
        }
        fn set_decay_rate(ref self: ContractState, _decayRate: u256){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.decayRate.write(_decayRate);
        }
        fn record_mint_event(ref self: ContractState){
            assert!(get_caller_address() == self.minter.read(), "!minter");
            self.inflationRate.write(self.inflationRate.read() * ((pow(10_u128,18_u128).into() - self.decayRate.read())));
            self.nextMintTime.write(self.nextMintTime.read() + self.mintDuration.read());
        }
        fn mintable_supply(self: @ContractState) -> u256{
            if(!self.is_mintable()) {
                return 0;
            }
            let ifnxToken: ContractAddress = iminterDispatcher{contract_address: self.minter.read()}.get_ifnx_token();
            let totalSupply: u256 = ierc20Dispatcher{contract_address: ifnxToken}.total_supply();
            if(get_block_timestamp().into() >= self.supplyDecayEndTime.read()){
                return totalSupply * TERMINAL_SUPPLY_EPOCH_RATE;
            }
            return totalSupply * self.inflationRate.read();
        }
        fn is_mintable(self: @ContractState) -> bool{
            if(self.nextMintTime.read() == 0){
                return false;
            }
            return get_block_timestamp().into() >= self.nextMintTime.read();
        }
        fn is_started(self: @ContractState) -> bool{
            return self.nextMintTime.read() > 0;
        }
    }

}