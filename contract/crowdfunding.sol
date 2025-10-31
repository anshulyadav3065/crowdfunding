// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GreenFund - A decentralized crowdfunding platform for eco-friendly initiatives
/// @author 
/// @notice This contract allows users to create and fund environmental projects on-chain
contract GreenFund {
    address public owner;

    struct Project {
        string name;
        string description;
        address payable creator;
        uint256 goal;
        uint256 fundsRaised;
        bool completed;
    }

    Project[] public projects;

    event ProjectCreated(uint256 indexed projectId, string name, uint256 goal, address creator);
    event Funded(uint256 indexed projectId, address indexed funder, uint256 amount);
    event ProjectCompleted(uint256 indexed projectId, uint256 totalFunds);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Create a new eco project
    function createProject(string memory _name, string memory _description, uint256 _goal) external {
        require(_goal > 0, "Goal must be greater than 0");

        projects.push(Project({
            name: _name,
            description: _description,
            creator: payable(msg.sender),
            goal: _goal,
            fundsRaised: 0,
            completed: false
        }));

        emit ProjectCreated(projects.length - 1, _name, _goal, msg.sender);
    }

    /// @notice Fund an existing project
    function fundProject(uint256 _projectId) external payable {
        require(_projectId < projects.length, "Project does not exist");
        Project storage project = projects[_projectId];
        require(!project.completed, "Project already completed");
        require(msg.value > 0, "Send some ETH");

        project.fundsRaised += msg.value;
        project.creator.transfer(msg.value);

        if (project.fundsRaised >= project.goal) {
            project.completed = true;
            emit ProjectCompleted(_projectId, project.fundsRaised);
        }

        emit Funded(_projectId, msg.sender, msg.value);
    }

    /// @notice View all projects
    function getAllProjects() external view returns (Project[] memory) {
        return projects;
    }
}

