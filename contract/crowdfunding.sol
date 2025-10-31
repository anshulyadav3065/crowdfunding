// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title GreenFund - A decentralized crowdfunding platform for eco-friendly initiatives
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
    event GoalUpdated(uint256 indexed projectId, uint256 oldGoal, uint256 newGoal);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    modifier onlyCreator(uint256 _projectId) {
        require(_projectId < projects.length, "Project does not exist");
        require(projects[_projectId].creator == msg.sender, "Only project creator can call this");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    /// @notice Create a new eco project
    function createProject(
        string memory _name,
        string memory _description,
        uint256 _goal
    ) external {
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

    /// @notice View a specific project by ID
    function getProject(uint256 _projectId)
        external
        view
        returns (
            string memory name,
            string memory description,
            address creator,
            uint256 goal,
            uint256 fundsRaised,
            bool completed
        )
    {
        require(_projectId < projects.length, "Project does not exist");
        Project memory p = projects[_projectId];
        return (p.name, p.description, p.creator, p.goal, p.fundsRaised, p.completed);
    }

    /// @notice Update a project’s funding goal before completion
    function updateGoal(uint256 _projectId, uint256 _newGoal)
        external
        onlyCreator(_projectId)
    {
        Project storage project = projects[_projectId];
        require(!project.completed, "Cannot update completed project");
        require(_newGoal > project.fundsRaised, "New goal must exceed funds raised");

        uint256 oldGoal = project.goal;
        project.goal = _newGoal;

        emit GoalUpdated(_projectId, oldGoal, _newGoal);
    }
}


