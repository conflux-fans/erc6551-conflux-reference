// SPDX-License-Identifier: MIT
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
