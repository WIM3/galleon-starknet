use starknet::{ContractAddress};

#[starknet::interface]
pub trait iifou<TContractState> {
    
    fn ownable_init(ref self: TContractState);
    fn ownable_init_unchained(ref self: TContractState);
    fn owner(self: @TContractState) -> ContractAddress;
    fn candidate(self: @TContractState) -> ContractAddress;
    fn renounceOwnership(ref self: TContractState);
    fn set_owner(ref self: TContractState, newOwner: ContractAddress);
    fn update_owner(ref self: TContractState);    
}

#[starknet::contract]
pub mod ifnx_fi_ownable_upgrade{
    use core::starknet::event::EventEmitter;
use starknet::{ContractAddress};
    use starknet::get_caller_address;
    use super::iifou;
    use starknet::contract_address_const;

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
        candidate: ContractAddress
    }

    #[external(v0)]
    impl ifnx_fi_ownable_upgrade of iifou<ContractState> {
        fn ownable_init(ref self: ContractState){
            self.ownable_init_unchained();
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
}