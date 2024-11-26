use core::array::ArrayTrait;
#[starknet::contract]
pub mod rewards_distribution{
    use core::clone::Clone;
    use core::traits::TryInto;
    use core::traits::Into;
    use galleon_starknet::contracts::interface::ireward_recipient::ireward_recipientDispatcherTrait;
    use galleon_starknet::contracts::interface::ierc20::ierc20DispatcherTrait;
    use starknet::{ContractAddress};
    use core::array::{Array};
    use core::array::SpanTrait;
    use core::array::ArrayTrait;
    use starknet::get_caller_address;
    use starknet::contract_address_const;
    use starknet::get_contract_address;
    use starknet::get_block_timestamp;
    use starknet::get_block_info;
    use galleon_starknet::contracts::interface::irewards_distribution::{irewards_distribution};
    use galleon_starknet::contracts::interface::ierc20::{ierc20Dispatcher};
    use galleon_starknet::contracts::interface::ireward_recipient::{ireward_recipientDispatcher};

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        OwnershipTransferred: OwnershipTransferred,
        RewardDistributed: RewardDistributed
    }

    #[derive(Drop, starknet::Event)]
    struct OwnershipTransferred{
        previousOwner: ContractAddress,
        newOwner: ContractAddress
    }

    #[derive(Drop, starknet::Event)]
    struct RewardDistributed{
        reward: u256,
        timestamp: u256
    }

    #[derive(Drop, Copy, Serde)]
    struct DistributionData {
        destination: ContractAddress,
        amount: u256
    }

    #[storage]
    struct Storage {
        owner: ContractAddress,
        candidate: ContractAddress,
        rewardsController: ContractAddress,
        defaultRecipient: ContractAddress,
        distributions: Array<DistributionData>
    }

    fn constructor(
        ref self: ContractState,
        _rewardsController: ContractAddress,
        _defaultRecipient: ContractAddress
    ) {
        ownable_init(ref self);
        self.rewardsController.write(_rewardsController);
        self.defaultRecipient.write(_defaultRecipient);
        self.distributions.write(ArrayTrait::new());
    }

    fn ownable_init(ref self: ContractState){
        let mut msgSender: ContractAddress = get_caller_address();
        self.owner.write(msgSender);
        self.emit(OwnershipTransferred{previousOwner: contract_address_const::<0>(), newOwner: msgSender});    
    }
 
    impl rewards_distribution of irewards_distribution<ContractState> {
        fn distribute_rewards(ref self: ContractState, _ifnxToken: ContractAddress, _amount: u256){
            assert!(get_caller_address() == self.rewardsController.read(), "!_rewardsController");
            let balance = ierc20Dispatcher{contract_address: _ifnxToken}.balance_of(get_contract_address());
            assert!(balance >= _amount, "not enough Ifnx");
            let mut remainder = _amount;
            let mut c = 0;
            let mut _distributions = self.distributions.read().span();
            
            while c < _distributions.len() {
                let DistributionData {destination ,amount} = *_distributions[c];
                if(destination != contract_address_const::<0>() && amount != 0){
                    remainder = remainder - amount;
                    ierc20Dispatcher{contract_address: _ifnxToken}.transfer(destination, amount);
                    ireward_recipientDispatcher{contract_address: destination}.notify_reward_amount(amount);
                }
            };

            ierc20Dispatcher{contract_address: _ifnxToken}.transfer(self.defaultRecipient.read(), remainder);
            ireward_recipientDispatcher{contract_address: self.defaultRecipient.read()}.notify_reward_amount(remainder);
            self.emit(RewardDistributed{reward: _amount, timestamp: get_block_timestamp().into()})
        }
    
        fn add_rewards_distribution(ref self: ContractState, _destination: ContractAddress, _amount: u256){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            assert!(_destination != contract_address_const::<0>(), "Cant add a zero address");
            assert!(_amount != 0, "Cant add a zero amount");
            let rewardsDistribution: DistributionData = DistributionData{
                destination: _destination,
                amount: _amount
            };
            let mut _distributions = self.distributions.read();
            _distributions.append(rewardsDistribution);
            self.distributions.write(_distributions);
        }
        fn remove_rewards_distribution(ref self: ContractState, _index: u256){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            assert!(self.distributions.read().len() != 0 && _index <= self.distributions.read().len().into() - 1, "index out of bounds");
            let _distributions = self.distributions.read().clone();
            if(_index < self.distributions.read().len().into() - 1){
                self.distributions.write(write_at(self.distributions.read().clone(), _index, *_distributions[self.distributions.read().len() - 1]))
            }
            self.distributions.write(pop(self.distributions.read()));
        }
        fn edit_rewards_distribution(ref self: ContractState, _index: u256, _destination: ContractAddress, _amount: u256){
            assert!(get_caller_address() == self.owner.read(), "not the owner");
            assert!(self.distributions.read().len() != 0 && _index <= self.distributions.read().len().into() - 1, "index out of bounds");
            let rewardsDistribution: DistributionData = DistributionData{
                destination: _destination,
                amount: _amount
            };
            self.distributions.write(write_at(self.distributions.read().clone(), _index, rewardsDistribution))
        }
    
    
    }

    fn write_at(arr: Array<DistributionData>, _index: u256, _data: DistributionData) -> Array<DistributionData>{
        let mut c: u32 = 0;
        let mut newArr: Array<DistributionData> = ArrayTrait::new();
        while c < arr.len() {
            if(_index == c.into()){
                newArr.append(_data);
                continue;
            }
            newArr.append(*arr[c]);
        };
        return newArr;
    }

    fn pop(arr: Array<DistributionData>) -> Array<DistributionData>{
        let mut c: u32 = 0;
        let mut newArr: Array<DistributionData> = ArrayTrait::new();
        while c < arr.len() - 1 {
            newArr.append(*arr[c]);
        };
        return newArr;
    }
}