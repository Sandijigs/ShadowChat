use core::array::Array;
use starknet::ContractAddress;

// Define the contract interface
#[starknet::interface]
pub trait IMessageStorage<TContractState> {
    fn store_message(ref self: TContractState, recipient: ContractAddress, message: ByteArray);
    fn get_message(self: @TContractState, recipient: ContractAddress, index: u64) -> ByteArray;
    fn get_all_messages(self: @TContractState, recipient: ContractAddress) -> Array<ByteArray>;
    fn delete_message(ref self: TContractState, recipient: ContractAddress, index: u64);
    fn delete_all_messages(ref self: TContractState, recipient: ContractAddress);
}

// Define the contract module
#[starknet::contract]
pub mod MessageStorage {
    use core::array::{Array, ArrayTrait};
    use starknet::ContractAddress;
    use starknet::storage::{Map, StorageMapReadAccess, StorageMapWriteAccess};
    use super::IMessageStorage;

    // Define storage variables
    #[storage]
    struct Storage {
        messages: Map<(ContractAddress, u64), ByteArray>,
        message_counter: Map<ContractAddress, u64>,
    }

    // Implement the contract interface
    #[abi(embed_v0)]
    impl MessageStorageImpl of IMessageStorage<ContractState> {
        // Store a message
        fn store_message(ref self: ContractState, recipient: ContractAddress, message: ByteArray) {
            // Check if message is empty
            assert(message.len() != 0, 'Message cannot be empty');

            // Get the current counter for the recipient
            let current_index = self.message_counter.read(recipient);

            // Store the message
            self.messages.write((recipient, current_index), message);

            // Increment the counter
            self.message_counter.write(recipient, current_index + 1);
        }

        // Get a specific message
        fn get_message(self: @ContractState, recipient: ContractAddress, index: u64) -> ByteArray {
            // Check if the index is valid
            let total_messages = self.message_counter.read(recipient);
            assert(index < total_messages, 'Index out of bounds');

            // Return the message
            self.messages.read((recipient, index))
        }

        // Get all messages for a recipient
        fn get_all_messages(self: @ContractState, recipient: ContractAddress) -> Array<ByteArray> {
            // Get the total number of messages for the recipient
            let total_messages = self.message_counter.read(recipient);

            // Create a new array to store the messages
            let mut messages: Array<ByteArray> = ArrayTrait::new();

            // Iterate through the recipient's messages and append them to the array
            let mut i: u64 = 0;
            while i < total_messages {
                messages.append(self.messages.read((recipient, i)));
                i += 1;
            }

            // Return the array of messages
            messages
        }

        // Delete a specific message by index
        fn delete_message(ref self: ContractState, recipient: ContractAddress, index: u64) {
            let total_messages = self.message_counter.read(recipient);

            // Validate index
            assert(index < total_messages, 'Invalid message index');

            // Shift all messages after the deleted index
            let mut i = index;
            while i < total_messages - 1 {
                let next_message = self.messages.read((recipient, i + 1));
                self.messages.write((recipient, i), next_message);
                i += 1;
            }

            // Decrement the counter
            self.message_counter.write(recipient, total_messages - 1);
        }

        // Delete all messages for a recipient
        fn delete_all_messages(ref self: ContractState, recipient: ContractAddress) {
            // Reset the counter to 0
            self.message_counter.write(recipient, 0);
        }
    }
}

