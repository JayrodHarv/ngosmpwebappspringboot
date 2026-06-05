package com.jayrodharv.ngosmpwebappspringboot.service;

import org.springframework.stereotype.Service;
import com.jayrodharv.ngosmpwebappspringboot.dao.VoteDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.Image;
import com.jayrodharv.ngosmpwebappspringboot.model.UserVoteVM;
import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOptionVM;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteVM;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class VoteService {

    private final VoteDAO voteDao;
    private final ImageService imageService;

    public VoteService(VoteDAO voteDao, ImageService imageService) {
        this.voteDao = voteDao; this.imageService = imageService;
    }

    // ── Votes ─────────────────────────────────────────────────────────────────

    public List<VoteVM> findActiveVotes(int page, int size) {
        int offset = (page - 1) * size;
        return voteDao.findActiveVotes(size, offset);
    }
    public int countActiveVotes() {
        return voteDao.countActiveVotes();
    }

    public List<VoteVM> findPendingVotes(String userId, int page, int size) {
        int offset = (page - 1) * size;
        return voteDao.findPendingVotes(userId, size, offset);
    }
    public int countPendingVotes() {
        return voteDao.countPendingVotes();
    }

    public List<VoteVM> findDraftVotes(String userId, int page, int size) {
        int offset = (page - 1) * size;
        return voteDao.findDraftVotes(userId, size, offset);
    }
    public int countDraftVotes(String userId) {
        return voteDao.countDraftVotes(userId);
    }

    public List<VoteVM> findConcludedVotes(int page, int size) {
        int offset = (page - 1) * size;
        return voteDao.findConcludedVotes(size, offset);
    }
    public int countConcludedVotes() {
        return voteDao.countConcludedVotes();
    }

    public Optional<VoteVM> findByUser(String userId) {
        return voteDao.findByUser(userId);
    }
    public VoteVM findById(String id){
        return voteDao.findById(id)
            .orElseThrow(() -> new IllegalArgumentException("Vote not found"));
    }

    public void create(Vote vote)                   { voteDao.insert(vote); }
    public void update(Vote vote)                   { voteDao.update(vote); }
    public void publishVote(String voteId, LocalDateTime startTime, LocalDateTime endTime) {
        voteDao.publishVote(voteId, startTime, endTime);
    }
    public void delete(String voteId)               { voteDao.deleteById(voteId); }

    // ── Options ───────────────────────────────────────────────────────────────

    public List<VoteOptionVM> findOptions(String voteId) {
        List<VoteOptionVM> options = voteDao.findOptions(voteId);

        // Load images for options that have them
        for (VoteOptionVM option : options) {
            if (option.getImageId() != null) {
                Optional<Image> imgOpt = imageService.findById(option.getImageId());
                imgOpt.ifPresent(option::setImage);
            }
        }

        return options;
    }
    public void addOption(VoteOption option)            { voteDao.insertOption(option); }
    public void updateOption(VoteOption option)         { voteDao.updateOption(option); }
    public void removeOption(int optionId)              { voteDao.deleteOption(optionId); }

    // ── Casting ───────────────────────────────────────────────────────────────

    /**
     * Cast or change a vote. The UNIQUE constraint on UserVote prevents
     * double-voting; this method wraps the SP call.
     */
    public void cast(String userId, String voteId, int optionId) {
        voteDao.castVote(userId, voteId, optionId);
    }

    public List<UserVoteVM> findUserVotes(String voteId) {
        return voteDao.findUserVotes(voteId);
    }
}
