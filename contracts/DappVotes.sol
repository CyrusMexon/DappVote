//SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;
import '@openzeppelin/contracts/utils/Counters.sol'; // A library to help with counting

contract DappVotes {
  using Counters for Counters.Counter;
  Counters.Counter private totalPolls;
  Counters.Counter private totalContestants;

  struct PollStruct {
    uint id;
    string image;
    string title;
    string description;
    uint votes;
    uint contestants;
    bool deleted; // Will be used to delete polls
    address director; // Director(Creator) of the poll
    uint startsAt;
    uint endsAt;
    uint timestamp; // keeps track of the time when the poll was created
    address[] voters; // keeps track of the voters in the poll
    string[] avatars;
  }

  struct ContestantStruct {
    uint id;
    string image;
    string name;
    address voter;
    uint votes;
    address[] voters; // people who voted for this contestant
  }

  mapping(uint => bool) pollExist;
  mapping(uint => PollStruct) polls; //Keeps track of every poll created
  mapping(uint => mapping(address => bool)) voted;
  mapping(uint => mapping(address => bool)) contested;
  mapping(uint => mapping(uint => ContestantStruct)) contestants; // Contestants of each poll

  event Voted(address indexed voter, uint timestamp);

  function createPoll(
    string memory image,
    string memory title,
    string memory description,
    uint startsAt,
    uint endsAt
  ) public {
    require(bytes(title).length > 0, 'Title cannot be empty!');
    require(bytes(description).length > 0, 'Description cannot be empty!');
    require(bytes(image).length > 0, 'Image URL cannot be empty!');
    require(startsAt > 0, 'Start date must be greater than 0!');
    require(endsAt > startsAt, 'End date must be greater than start date!');

    totalPolls.increment();

    PollStruct memory poll;
    poll.id = totalPolls.current();
    poll.title = title;
    poll.description = description;
    poll.image = image;
    poll.startsAt = startsAt;
    poll.endsAt = endsAt;
    poll.director = msg.sender;
    poll.timestamp = currentTime();

    polls[poll.id] = poll;
    pollExist[poll.id] = true;
  }

  function updatePoll(
    uint id,
    string memory image,
    string memory title,
    string memory description,
    uint startsAt,
    uint endsAt
  ) public {
    require(pollExist[id], 'Poll does not exist!');
    require(msg.sender == polls[id].director, 'Only the creator of the poll can update it!');
    require(bytes(title).length > 0, 'Title cannot be empty!');
    require(bytes(description).length > 0, 'Description cannot be empty!');
    require(bytes(image).length > 0, 'Image URL cannot be empty!');
    require(!polls[id].deleted, 'Poll has already been deleted!');
    require(polls[id].votes < 1, 'Poll already has votes!');
    require(endsAt > startsAt, 'End date must be greater than start date!');

    polls[id].title = title;
    polls[id].description = description;
    polls[id].startsAt = startsAt;
    polls[id].endsAt = endsAt;
    polls[id].image = image;
  }

  function deletePoll(uint id) public {
    require(pollExist[id], 'Poll does not exist!');
    require(msg.sender == polls[id].director, 'Only the creator of the poll can delete it!');
    require(polls[id].votes < 1, 'Poll already has votes!');
    polls[id].deleted = true;
  }

  //Function to retrieve a poll
  function getPoll(uint id) public view returns (PollStruct memory) {
    return polls[id];
  }

  //Function to retrieve all polls
  function getPolls() public view returns (PollStruct[] memory Polls) {
    uint available;
    //.current() returns the number of elements in the poll array
    // Looping to get all available polls
    for (uint i = 1; i <= totalPolls.current(); i++) {
      if (!polls[i].deleted) available++;
    }
    // Defining the size of the Polls array
    Polls = new PollStruct[](available);
    uint index;

    // Iterating through the poll array and adding the available polls to the Polls array
    for (uint i = 1; i <= totalPolls.current(); i++) {
      if (!polls[i].deleted) {
        Polls[index++] = polls[i];
      }
    }
  }

  //Function to create a contestant
  function contest(uint id, string memory name, string memory image) public {
    require(pollExist[id], 'Poll does not exist!');
    require(bytes(name).length > 0, 'Name cannot be empty!');
    require(bytes(image).length > 0, 'Image cannot be empty!');
    require(polls[id].votes < 1, 'Poll has votes already!');
    require(!contested[id][msg.sender], 'Contestant already exists!');

    totalContestants.increment();

    ContestantStruct memory contestant;
    contestant.name = name;
    contestant.image = image;
    contestant.voter = msg.sender;
    contestant.id = totalContestants.current();

    contestants[id][contestant.id] = contestant;
    contested[id][msg.sender] = true; //Saying user has contested for the given poll
    polls[id].avatars.push(image);
    polls[id].contestants++; //Incrementing the number of contestants for the poll
  }

  //Getting a contestant from a specific poll (id)
  function getContestant(uint id, uint cid) public view returns (ContestantStruct memory) {
    return contestants[id][cid];
  }

  function getContestants(uint id) public view returns (ContestantStruct[] memory Contestants) {
    uint available;

    for (uint i = 1; i <= totalContestants.current(); i++) {
      if (contestants[id][i].id == i) available++;
    }

    Contestants = new ContestantStruct[](available);
    uint index;

    for (uint i = 1; i <= totalContestants.current(); i++) {
      if (contestants[id][i].id == i) {
        Contestants[index++] = contestants[id][i];
      }
    }
  }

  function vote(uint id, uint cid) public {
    require(pollExist[id], 'Poll does not exist');
    require(!voted[id][msg.sender], 'You have already voted!');
    require(!polls[id].deleted, 'Poll has been deleted');
    require(polls[id].contestants > 1, 'Not enough contestants!');
    //Limiting the vote to the time range that has been assigned
    require(
      currentTime() >= polls[id].startsAt && currentTime() <= polls[id].endsAt,
      'Voting time has ended or has not started yet!'
    );

    polls[id].votes++;
    polls[id].voters.push(msg.sender); //Add voter to the list of voters for that poll

    contestants[id][cid].votes++;
    contestants[id][cid].voters.push(msg.sender); //Add voter to the list of voters for that contestant
    voted[id][msg.sender] = true; //Set the voter as having voted

    emit Voted(msg.sender, currentTime());
  }

  // Gives us a 13-digit timestamp instead of the solidity 10-digit timestamp
  function currentTime() internal view returns (uint256) {
    return (block.timestamp * 1000) + 1000;
  }
}
