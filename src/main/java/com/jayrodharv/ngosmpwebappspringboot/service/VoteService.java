package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.stereotype.Service;
import com.jayrodharv.ngosmpwebappspringboot.dao.VoteDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.UserVote;
import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;

import java.util.List;
import java.util.Optional;

@Service
public class VoteService {

    private final VoteDAO voteDao;

    public VoteService(VoteDAO voteDao) { this.voteDao = voteDao; }

    // ── Votes ─────────────────────────────────────────────────────────────────

    public List<Vote> findActive()              { return voteDao.findActive(); }
    public List<Vote> findConcluded()           { return voteDao.findConcluded(); }
    public Optional<Vote> findById(String id)   { return voteDao.findById(id); }
    public void create(Vote vote)               { voteDao.insert(vote); }
    public void update(Vote vote)               { voteDao.update(vote); }
    public void delete(String voteId)           { voteDao.deleteById(voteId); }

    // ── Options ───────────────────────────────────────────────────────────────

    public List<VoteOption> findOptions(String voteId) { return voteDao.findOptions(voteId); }
    public void addOption(VoteOption option)            { voteDao.insertOption(option); }
    public void removeOption(int optionId)              { voteDao.deleteOption(optionId); }

    // ── Casting ───────────────────────────────────────────────────────────────

    /**
     * Cast or change a vote. The UNIQUE constraint on UserVote prevents
     * double-voting; this method wraps the SP call.
     */
    public void cast(String userId, String voteId, int optionId) {
        voteDao.castVote(userId, voteId, optionId);
    }

    public List<UserVote> findUserVotes(String voteId) {
        return voteDao.findUserVotes(voteId);
    }
}
