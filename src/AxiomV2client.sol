// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import "./external/interfaces/IAxiomV2Client.sol";

abstract contract AxiomV2Client is IAxiomV2Client {
    address public immutable axiomV2QueryAddress;

    constructor(address _axiomV2QueryAddress) {
        axiomV2QueryAddress = _axiomV2QueryAddress;
    }

    function axiomV2Callback(
        uint64 sourceChainId,
        address callerAddr,
        bytes32 querySchema,
        bytes32 queryHash,
        bytes32[] calldata axiomResults,
        bytes calldata callbackExtraData
    ) external {
        require(
            msg.sender == axiomV2QueryAddress,
            "AxiomV2Client: caller must be axiomV2QueryAddress"
        );
        emit AxiomV2Call(sourceChainId, callerAddr, querySchema, queryHash);

        _validateAxiomV2Call(sourceChainId, callerAddr, querySchema);
        _axiomV2Callback(
            sourceChainId,
            callerAddr,
            querySchema,
            queryHash,
            axiomResults,
            callbackExtraData
        );
    }

    function _validateAxiomV2Call(
        uint64 sourceChainId,
        address callerAddr,
        bytes32 querySchema
    ) internal virtual;

    function _axiomV2Callback(
        uint64 sourceChainId,
        address callerAddr,
        bytes32 querySchema,
        bytes32 queryHash,
        bytes32[] calldata axiomResults,
        bytes calldata callbackExtraData
    ) internal virtual;
}
