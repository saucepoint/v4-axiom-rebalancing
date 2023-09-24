// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

interface IAxiomV2Client {
    event AxiomV2Call(
        uint64 indexed sourceChainId,
        address callerAddr,
        bytes32 indexed querySchema,
        bytes32 indexed queryHash
    );

    function axiomV2QueryAddress() external view returns (address);

    function axiomV2Callback(
        uint64 sourceChainId,
        address callerAddr,
        bytes32 querySchema,
        bytes32 queryHash,
        bytes32[] calldata axiomResults,
        bytes calldata callbackExtraData
    ) external;
}
