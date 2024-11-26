#[starknet::contract]
pub mod minter{
    use galleon_starknet::contracts::interface::iinflation_monitor::iinflation_monitorDispatcherTrait;
use galleon_starknet::contracts::interface::irewards_distribution::irewards_distributionDispatcherTrait;
use galleon_starknet::contracts::interface::iifnx_token::iifnx_tokenDispatcherTrait;
use galleon_starknet::contracts::interface::isupply_schedule::isupply_scheduleDispatcherTrait;
use starknet::{ContractAddress};
    use galleon_starknet::contracts::interface::iminter::{iminter};
    use galleon_starknet::contracts::interface::isupply_schedule::{isupply_scheduleDispatcher};
    use galleon_starknet::contracts::interface::iifnx_token::{iifnx_tokenDispatcher};
    use galleon_starknet::contracts::interface::irewards_distribution::{irewards_distributionDispatcher};
    use galleon_starknet::contracts::interface::iinflation_monitor::{iinflation_monitorDispatcher};
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::get_block_timestamp;
    use starknet::get_block_info;

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred,
        IfnxMinted: IfnxMinted
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred{
        previousOwner: ContractAddress,
        newOwner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct IfnxMinted{
        amount: u256
    }

    #[storage]
    struct Storage {
        owner: ContractAddress,
        candidate: ContractAddress,
        ifnxToken: ContractAddress,
        supplySchedule: ContractAddress,
        rewardsDistribution: ContractAddress,
        inflationMonitor: ContractAddress,
        insuranceFund: ContractAddress
    }

    fn constructor(
        ref self: ContractState,
        _ifnxToken: ContractAddress
    ) {
        ownable_init(ref self);
        self.ifnxToken.write(_ifnxToken);
    }

    #[abi(embed_v0)]
    impl minter of iminter<ContractState> {
        fn mint_reward(ref self: ContractState){
            let mintableSupply = isupply_scheduleDispatcher{contract_address: self.supplySchedule.read()}.mintable_supply();
            assert!(mintableSupply > 0, "no supply is mintable");
            iifnx_tokenDispatcher{contract_address: self.ifnxToken.read()}.mint(self.rewardsDistribution.read(), mintableSupply);
            irewards_distributionDispatcher{contract_address: self.rewardsDistribution.read()}.distribute_rewards(self.ifnxToken.read(), mintableSupply);
            isupply_scheduleDispatcher{contract_address: self.supplySchedule.read()}.record_mint_event();
            self.emit(IfnxMinted{amount: mintableSupply});
        }
        fn mint_for_loss(ref self: ContractState, _amount: u256){
            assert!(self.insuranceFund.read() == get_caller_address(), "only insuranceFund");
            assert!(self.inflationMonitor.read() != contract_address_const::<0>(), "inflationMonitor not fount");
            iifnx_tokenDispatcher{contract_address: self.ifnxToken.read()}.mint(self.insuranceFund.read(), _amount);
            iinflation_monitorDispatcher{contract_address: self.inflationMonitor.read()}.append_minted_token_history(_amount);
            self.emit(IfnxMinted{amount: _amount}); 
        }
        fn get_ifnx_token(self: @ContractState) -> ContractAddress{
            return self.ifnxToken.read();
        }
        fn set_insurance_fund(ref self: ContractState, _insuranceFund: ContractAddress){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.insuranceFund.write(_insuranceFund);
        }
        fn set_rewards_distribution(ref self: ContractState, _rewardsDistribution: ContractAddress){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.rewardsDistribution.write(_rewardsDistribution);
        }
        fn set_supply_schedule(ref self: ContractState, _supplySchedule: ContractAddress){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.supplySchedule.write(_supplySchedule);
        }
        fn set_inflation_monitor(ref self: ContractState, _inflationMonitor: ContractAddress){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            self.inflationMonitor.write(_inflationMonitor);
        }

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

}
