// Sources flattened with hardhat v2.17.2 https://hardhat.org

// SPDX-License-Identifier: MIT

// File src/interfaces/IERC6551Registry.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

interface IERC6551Registry {
    /**
     * @dev The registry SHALL emit the AccountCreated event upon successful account creation
     */
    event AccountCreated(
        address account,
        address indexed implementation,
        uint256 chainId,
        address indexed tokenContract,
        uint256 indexed tokenId,
        uint256 salt
    );

    /**
     * @dev Creates a token bound account for a non-fungible token
     *
     * If account has already been created, returns the account address without calling create2
     *
     * If initData is not empty and account has not yet been created, calls account with
     * provided initData after creation
     *
     * Emits AccountCreated event
     *
     * @return the address of the account
     */
    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 seed,
        bytes calldata initData
    ) external returns (address);

    /**
     * @dev Returns the computed token bound account address for a non-fungible token
     *
     * @return The computed address of the token bound account
     */
    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address);
}


// File src/lib/Create2.sol

// Original license: SPDX_License_Identifier: MIT
// Forked from
// OpenZeppelin Contracts (last updated v4.7.0) (utils/Create2.sol)

pragma solidity ^0.8.0;

/**
 * @dev Helper to make usage of the `CREATE2` EVM opcode easier and safer.
 * `CREATE2` can be used to compute in advance the address where a smart
 * contract will be deployed, which allows for interesting new mechanisms known
 * as 'counterfactual interactions'.
 *
 * See the https://eips.ethereum.org/EIPS/eip-1014#motivation[EIP] for more
 * information.
 */
library Create2 {
    /**
     * @dev Deploys a contract using `CREATE2`. The address where the contract
     * will be deployed can be known in advance via {computeAddress}.
     *
     * The bytecode for a contract can be obtained from Solidity with
     * `type(contractName).creationCode`.
     *
     * Requirements:
     *
     * - `bytecode` must not be empty.
     * - `salt` must have not been used for `bytecode` already.
     * - the factory must have a balance of at least `amount`.
     * - if `amount` is non-zero, `bytecode` must have a `payable` constructor.
     */
    function deploy(
        uint256 amount,
        bytes32 salt,
        bytes memory bytecode
    ) internal returns (address addr) {
        require(address(this).balance >= amount, "Create2: insufficient balance");
        require(bytecode.length != 0, "Create2: bytecode length is zero");
        /// @solidity memory-safe-assembly
        assembly {
            addr := create2(amount, add(bytecode, 0x20), mload(bytecode), salt)
        }
        require(addr != address(0), "Create2: Failed on deploy");
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy}. Any change in the
     * `bytecodeHash` or `salt` will result in a new destination address.
     */
    function computeAddress(bytes32 salt, bytes32 bytecodeHash) internal view returns (address) {
        return computeAddress(salt, bytecodeHash, address(this));
    }

    /**
     * @dev Returns the address where a contract will be stored if deployed via {deploy} from a contract located at
     * `deployer`. If `deployer` is this contract's address, returns the same value as {computeAddress}.
     */
    function computeAddress(
        bytes32 salt,
        bytes32 bytecodeHash,
        address deployer
    ) internal pure returns (address addr) {
        /// @solidity memory-safe-assembly
        assembly {
            let ptr := mload(0x40) // Get free memory pointer

            // |                   | ↓ ptr ...  ↓ ptr + 0x0B (start) ...  ↓ ptr + 0x20 ...  ↓ ptr + 0x40 ...   |
            // |-------------------|---------------------------------------------------------------------------|
            // | bytecodeHash      |                                                        CCCCCCCCCCCCC...CC |
            // | salt              |                                      BBBBBBBBBBBBB...BB                   |
            // | deployer          | 000000...0000AAAAAAAAAAAAAAAAAAA...AA                                     |
            // | 0xFF              |            FF                                                             |
            // |-------------------|---------------------------------------------------------------------------|
            // | memory            | 000000...00FFAAAAAAAAAAAAAAAAAAA...AABBBBBBBBBBBBB...BBCCCCCCCCCCCCC...CC |
            // | keccak(start, 85) |            ↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑ |

            mstore(add(ptr, 0x40), bytecodeHash)
            mstore(add(ptr, 0x20), salt)
            mstore(ptr, deployer) // Right-aligned with 12 preceding garbage bytes
            let start := add(ptr, 0x0b) // The hashed data starts at the final garbage byte which we will set to 0xff
            mstore8(start, 0xff)
            addr := keccak256(start, 85)
        }
        // make addr start as 0x8
        // addr = addr
        //      & 0x0FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
        //      | 0x8000000000000000000000000000000000000000
        addr = address((uint160(addr) & ((1 << 156) - 1)) | (1 << 159));
    }
}


// File src/lib/ERC6551BytecodeLib.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

library ERC6551BytecodeLib {
    // 0x3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b603f806100be6000396000f3fe(Compiled AdminSafe constructor)

    // =>

    // ...603f806100be6000396000f3fe(AdminSafe constructor)

    // =>

    // ...60(3f)8061(00be)6000396000f3fe(AdminSafe constructor)

    // 3f: code length
    // 00be: code start

    // == replace 3f with ad ==>

    // ...60ad806100be6000396000f3fe(AdminSafe constructor)

    // =>

    // 0x3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b60ad806100be6000396000f3fe(New Proxy Constructor)

    // == join with original runtime bytecode==>
    function getCreationCode(
        address implementation_,
        uint256 chainId_,
        address tokenContract_,
        uint256 tokenId_,
        uint256 salt_
    ) internal pure returns (bytes memory) {
        return
            abi.encodePacked(
                hex"3060a452600060c4526044608090815260e4604081905260a080516001600160e01b031663c55b6bb760e01b17905261011160931b91603c916083565b6000604051808303816000865af19150503d80600081146077576040519150601f19603f3d011682016040523d82523d6000602084013e607c565b606091505b50505060b0565b6000825160005b8181101560a25760208186018101518583015201608a565b506000920191825250919050565b60ad806100be6000396000f3fe",
                // hex"3d60ad80600a3d3981f3",
                hex"363d3d373d3d3d363d73",
                implementation_,
                hex"5af43d82803e903d91602b57fd5bf3",
                abi.encode(salt_, chainId_, tokenContract_, tokenId_)
            );
    }
}


// File src/ERC6551Registry.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;


contract ERC6551Registry is IERC6551Registry {
    error AccountCreationFailed();

    function createAccount(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt,
        bytes calldata initData
    ) external returns (address) {
        bytes memory code = ERC6551BytecodeLib.getCreationCode(
            implementation,
            chainId,
            tokenContract,
            tokenId,
            salt
        );

        address _account = Create2.computeAddress(bytes32(salt), keccak256(code));

        if (_account.code.length != 0) return _account;

        // the log might be invalid if tested in eth env
        emit AccountCreated(_account, implementation, chainId, tokenContract, tokenId, salt);

        assembly {
            _account := create2(0, add(code, 0x20), mload(code), salt)
        }

        if (_account == address(0)) revert AccountCreationFailed();

        if (initData.length != 0) {
            (bool success, bytes memory result) = _account.call(initData);

            if (!success) {
                assembly {
                    revert(add(result, 32), mload(result))
                }
            }
        }

        return _account;
    }

    function account(
        address implementation,
        uint256 chainId,
        address tokenContract,
        uint256 tokenId,
        uint256 salt
    ) external view returns (address) {
        bytes32 bytecodeHash = keccak256(
            ERC6551BytecodeLib.getCreationCode(
                implementation,
                chainId,
                tokenContract,
                tokenId,
                salt
            )
        );

        return Create2.computeAddress(bytes32(salt), bytecodeHash);
    }
}
