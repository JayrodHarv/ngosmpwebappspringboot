package com.jayrodharv.ngosmpwebappspringboot.dao;

import org.springframework.jdbc.core.RowMapper;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.stereotype.Repository;

import com.jayrodharv.ngosmpwebappspringboot.model.UserVote;
import com.jayrodharv.ngosmpwebappspringboot.model.Vote;
import com.jayrodharv.ngosmpwebappspringboot.model.VoteOption;

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

    private static final RowMapper<VoteOption> OPTION_MAPPER = (rs, rowNum) -> {
        VoteOption o = new VoteOption();
        o.setOptionId(rs.getInt("OptionID"));
        o.setVoteId(rs.getString("VoteID"));
        o.setTitle(rs.getString("Title"));
        o.setDescription(rs.getString("Description"));
        o.setImageId(rs.getObject("ImageID", Integer.class));
        o.setNumberOfVotes(rs.getInt("number_of_votes"));
        return o;
    };

    private static final RowMapper<UserVote> USER_VOTE_MAPPER = (rs, rowNum) -> new UserVote(
            rs.getString("UserID"),
            rs.getString("VoteID"),
            rs.getInt("OptionID"),
            rs.getTimestamp("VoteTime").toLocalDateTime()
    );

    // ── Vote CRUD ─────────────────────────────────────────────────────────────

    public List<Vote> findActive() {
        return jdbc.query("CALL sp_get_active_votes()", new MapSqlParameterSource(), VOTE_MAPPER);
    }

    public List<Vote> findConcluded() {
        return jdbc.query("CALL sp_get_concluded_votes()", new MapSqlParameterSource(), VOTE_MAPPER);
    }

    public Optional<Vote> findById(String voteId) {
        return jdbc.query(
                "CALL sp_get_vote(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                VOTE_MAPPER).stream().findFirst();
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

    public void deleteById(String voteId) {
        jdbc.update("CALL sp_delete_vote(:voteId)",
                new MapSqlParameterSource("voteId", voteId));
    }

    // ── VoteOption CRUD ───────────────────────────────────────────────────────

    public List<VoteOption> findOptions(String voteId) {
        return jdbc.query(
                "CALL sp_get_voteoptions(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                OPTION_MAPPER);
    }

    public Optional<VoteOption> findOption(int optionId) {
        return jdbc.query(
                "CALL sp_get_voteoption(:optionId)",
                new MapSqlParameterSource("optionId", optionId),
                OPTION_MAPPER).stream().findFirst();
    }

    public void insertOption(VoteOption option) {
        MapSqlParameterSource p = new MapSqlParameterSource();
        p.addValue("voteId",      option.getVoteId());
        p.addValue("title",       option.getTitle());
        p.addValue("description", option.getDescription());
        p.addValue("imageId",     option.getImageId());
        jdbc.update("CALL sp_insert_voteoption(:voteId,:title,:description,:imageId)", p);
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

    public List<UserVote> findUserVotes(String voteId) {
        return jdbc.query(
                "CALL sp_get_uservotes(:voteId)",
                new MapSqlParameterSource("voteId", voteId),
                USER_VOTE_MAPPER);
    }
}
