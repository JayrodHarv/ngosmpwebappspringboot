package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.UserVote;
import com.jayrodharv.ngosmpwebappspringboot.model.UserVoteVM;
import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOptionVM;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteVM;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
public class VoteDAO {

    private final NamedParameterJdbcTemplate jdbc;

    public VoteDAO(NamedParameterJdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    // ── Row Mappers ───────────────────────────────────────────────────────────

    private static final RowMapper<Vote> VOTE_MAPPER = (rs, rowNum) -> {
        Vote v = new Vote();
        v.setVoteId(rs.getString("VoteID"));
        v.setUserId(rs.getString("UserID"));
        v.setDescription(rs.getString("Description"));
        v.setStartTime(rs.getTimestamp("StartTime") != null
                ? rs.getTimestamp("StartTime").toLocalDateTime() : null);
        v.setEndTime(rs.getTimestamp("EndTime") != null
                ? rs.getTimestamp("EndTime").toLocalDateTime() : null);
        return v;
    };

    private static final RowMapper<VoteOption> VOTE_OPTION_MAPPER = (rs, rowNum) -> {
        VoteOption o = new VoteOption();
        o.setOptionId(rs.getInt("OptionID"));
        o.setVoteId(rs.getString("VoteID"));
        o.setTitle(rs.getString("Title"));
        o.setDescription(rs.getString("Description"));
        o.setImageId(rs.getObject("ImageID", Integer.class));
        return o;
    };

    private static final RowMapper<UserVote> USER_VOTE_MAPPER = (rs, rowNum) -> new UserVote(
            rs.getString("UserID"),
            rs.getString("VoteID"),
            rs.getInt("OptionID"),
            rs.getTimestamp("VoteTime").toLocalDateTime()
    );

     // ── Row Mappers for View Models ───────────────────────────────────────────

    // RowMapper for VoteOptionVM with Image
    private static final RowMapper<VoteOptionVM> VOTE_OPTION_VM_MAPPER = (rs, rowNum) -> {
        VoteOptionVM option = new VoteOptionVM();
        option.setOptionId(rs.getInt("OptionID"));
        option.setVoteId(rs.getString("VoteID"));
        option.setTitle(rs.getString("Title"));
        option.setDescription(rs.getString("Description"));
        option.setVoteCount(rs.getInt("total_votes"));
        
        // Handle Image if exists
        int imageId = rs.getInt("ImageID");
        if (!rs.wasNull() && imageId > 0) {
            option.setImageId(imageId);
        }
        
        return option;
    };

    // RowMapper for UserVoteVM
    private static final RowMapper<UserVoteVM> USER_VOTE_VM_MAPPER = (rs, rowNum) -> {
        UserVoteVM userVote = new UserVoteVM();
        userVote.setUserId(rs.getString("UserID"));
        userVote.setVoteId(rs.getString("VoteID"));
        userVote.setOptionId(rs.getInt("OptionID"));
        userVote.setVoteTime(rs.getTimestamp("VoteTime") != null 
                ? rs.getTimestamp("VoteTime").toLocalDateTime() : null);
        userVote.setDisplayName(rs.getString("DisplayName"));
        return userVote;
    };

    // RowMapper for VoteVM (complete vote with all details)
    private static final RowMapper<VoteVM> VOTE_VM_MAPPER = (rs, rowNum) -> {
        VoteVM vote = new VoteVM();
        vote.setVoteId(rs.getString("VoteID"));
        vote.setUserId(rs.getString("UserID"));
        vote.setDescription(rs.getString("Description"));
        vote.setStartTime(rs.getTimestamp("StartTime") != null 
                ? rs.getTimestamp("StartTime").toLocalDateTime() : null);
        vote.setEndTime(rs.getTimestamp("EndTime") != null 
                ? rs.getTimestamp("EndTime").toLocalDateTime() : null);
        vote.setDisplayName(rs.getString("DisplayName"));
        vote.setTotalOptions(rs.getInt("total_options"));
        vote.setTotalVotes(rs.getInt("total_votes"));
        return vote;
    };

    // -- Active Votes -----------------------------------------------------------
    public List<VoteVM> findActiveVotes(int limit, int offset) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("limit", limit);
        params.addValue("offset", offset);
        return jdbc.query("CALL sp_get_active_votes(:limit, :offset)", params, VOTE_VM_MAPPER);
    }

    public int countActiveVotes() {
        MapSqlParameterSource params = new MapSqlParameterSource();
        Integer count = jdbc.queryForObject("CALL sp_count_active_votes()", params, Integer.class);
        return count != null ? count : 0;
    }

    // -- Pending Votes ----------------------------------------------------------
    public List<VoteVM> findPendingVotes(String userId, int limit, int offset) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("userId", userId);
        params.addValue("limit", limit);
        params.addValue("offset", offset);
        return jdbc.query("CALL sp_get_pending_votes(:userId, :limit, :offset)", params, VOTE_VM_MAPPER);
    }

    public int countPendingVotes() {
        MapSqlParameterSource params = new MapSqlParameterSource();
        Integer count = jdbc.queryForObject("CALL sp_count_pending_votes()", params, Integer.class);
        return count != null ? count : 0;
    }

    // -- Draft Votes ----------------------------------------------------------
    public List<VoteVM> findDraftVotes(String userId, int limit, int offset) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("userId", userId);
        params.addValue("limit", limit);
        params.addValue("offset", offset);
        return jdbc.query("CALL sp_get_draft_votes(:userId, :limit, :offset)", params, VOTE_VM_MAPPER);
    }

    public int countDraftVotes() {
        MapSqlParameterSource params = new MapSqlParameterSource();
        Integer count = jdbc.queryForObject("CALL sp_count_draft_votes()", params, Integer.class);
        return count != null ? count : 0;
    }

    // -- Concluded Votes --------------------------------------------------------
    public List<VoteVM> findConcludedVotes(int limit, int offset) {
        MapSqlParameterSource params = new MapSqlParameterSource();
        params.addValue("limit", limit);
        params.addValue("offset", offset);
        return jdbc.query("CALL sp_get_concluded_votes(:limit, :offset)", params, VOTE_VM_MAPPER);
    }

    public int countConcludedVotes() {
        MapSqlParameterSource params = new MapSqlParameterSource();
        Integer count = jdbc.queryForObject("CALL sp_count_concluded_votes()", params, Integer.class);
        return count != null ? count : 0;
    }

    // ── Vote CRUD ─────────────────────────────────────────────────────────────

    public Optional<VoteVM> findById(String voteId) {
        return jdbc.query(
                "CALL sp_get_vote(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                VOTE_VM_MAPPER).stream().findFirst();
    }

    public Optional<VoteVM> findByUser(String userId) {
        return jdbc.query(
                "CALL sp_get_votes_by_user(:userId)",
                new MapSqlParameterSource("userId", userId),
                VOTE_VM_MAPPER).stream().findFirst();
    }

    public void insert(Vote vote) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("voteId",      vote.getVoteId());
        p.addValue("userId",      vote.getUserId());
        p.addValue("description", vote.getDescription());
        p.addValue("startTime",   vote.getStartTime());
        p.addValue("endTime",     vote.getEndTime());
        jdbc.update("CALL sp_insert_vote(:voteId,:userId,:description,:startTime,:endTime)", p);
    }

    public void update(Vote vote) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("voteId",      vote.getVoteId());
        p.addValue("description", vote.getDescription());
        p.addValue("startTime",   vote.getStartTime());
        p.addValue("endTime",     vote.getEndTime());
        jdbc.update("CALL sp_update_vote(:voteId,:description,:startTime,:endTime)", p);
    }

    public void publishVote(String voteId, LocalDateTime startTime, LocalDateTime endTime) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("voteId", voteId);
        p.addValue("startTime", startTime);
        p.addValue("endTime", endTime);
        jdbc.update("CALL sp_publish_vote(:voteId,:startTime,:endTime)", p);
    }

    public void deleteById(String voteId) {
        jdbc.update("CALL sp_delete_vote(:voteId)",
                new MapSqlParameterSource("voteId", voteId));
    }

    // ── VoteOption CRUD ───────────────────────────────────────────────────────

    public List<VoteOptionVM> findOptions(String voteId) {
        return jdbc.query(
                "CALL sp_get_voteoptions(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                VOTE_OPTION_VM_MAPPER);
    }

    public Optional<VoteOptionVM> findOption(int optionId) {
        return jdbc.query(
                "CALL sp_get_voteoption(:optionId)",
                new MapSqlParameterSource("optionId", optionId),
                VOTE_OPTION_VM_MAPPER).stream().findFirst();
    }

    public void insertOption(VoteOption option) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("voteId",      option.getVoteId());
        p.addValue("title",       option.getTitle());
        p.addValue("description", option.getDescription());
        p.addValue("imageId",     option.getImageId());
        jdbc.update("CALL sp_insert_voteoption(:voteId,:title,:description,:imageId)", p);
    }

    public void updateOption(VoteOption option) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("optionId",    option.getOptionId());
        p.addValue("title",       option.getTitle());
        p.addValue("description", option.getDescription());
        p.addValue("imageId",     option.getImageId());
        jdbc.update("CALL sp_update_voteoption(:optionId,:title,:description,:imageId)", p);
    }

    public void deleteOption(int optionId) {
        jdbc.update("CALL sp_delete_voteoption(:optionId)",
                new MapSqlParameterSource("optionId", optionId));
    }

    // ── UserVote ──────────────────────────────────────────────────────────────

    public void castVote(String userId, String voteId, int optionId) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("userId",   userId);
        p.addValue("voteId",   voteId);
        p.addValue("optionId", optionId);
        p.addValue("voteTime", java.time.LocalDateTime.now());
        jdbc.update("CALL sp_insert_uservote(:userId,:voteId,:optionId,:voteTime)", p);
    }

    public List<UserVoteVM> findUserVotes(String voteId) {
        return jdbc.query(
                "CALL sp_get_uservotes(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                USER_VOTE_VM_MAPPER);
    }
}
