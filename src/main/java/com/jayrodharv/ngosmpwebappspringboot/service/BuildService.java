package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildImageDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.TagDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildFormDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildListDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;
import com.jayrodharv.ngosmpwebappspringboot.logging.ActivityAction;
import com.jayrodharv.ngosmpwebappspringboot.logging.AppLogger;
import com.jayrodharv.ngosmpwebappspringboot.model.Permission;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageRequest;
import com.jayrodharv.ngosmpwebappspringboot.pagination.PageResult;

import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.Set;
import lombok.AllArgsConstructor;
import lombok.extern.slf4j.Slf4j;

import org.springframework.stereotype.Service;

@Slf4j
@Service
@AllArgsConstructor
public class BuildService {

    private final BuildImageDAO buildImageDAO;
    private final BuildDAO buildDAO;
    private final TagDAO tagDAO;
    private final CurrentUserService currentUserService;
    private final AuthorizationService auth;
    private final AppLogger logger;

    public PageResult<BuildListDTO> getBuilds(PageRequest request) {

        logger.action(ActivityAction.BUILD_LIST, "Attempting to view list of builds");
        PageResult<BuildListDTO> builds;
        try {

            builds = buildDAO.getBuilds(request);

            logger.action(ActivityAction.BUILD_LIST, "Successfully recieved " + builds.size() + " builds");

        } catch (Exception e) {
            logger.error("Failed to retrieve build list", e);
            throw e;
        }

        return builds;
    }

    public Integer createBuild(BuildFormDTO dto) {

        logger.action(ActivityAction.BUILD_CREATE, "Attempting to create build");

        CustomUserDetails currentUser = currentUserService.getCurrentUser();

        auth.requirePermission(currentUser , Permission.BUILD_CREATE);

        Set<Integer> finalTagIds = new HashSet<>(dto.tagIds());

        for (NewTagDTO tag : dto.newTags()) {
            Integer tagId = tagDAO.createOrGetTag(currentUser.getUserId(), tag);
            finalTagIds.add(tagId);
        }

        Integer buildId = buildDAO.createBuild(currentUser.getUserId(), dto);

        for (Integer tagId : finalTagIds) {
            buildDAO.addBuildTag(currentUser.getUserId(), buildId, tagId);
        }

        replaceImages(
            currentUser.getUserId(),
            buildId, dto.imageIds());

        logger.action(ActivityAction.BUILD_CREATE, "Successfully created build with id: " + buildId);

        return buildId;
    }

    public void replaceImages(Integer actingUserId, Integer buildId, List<Integer> imageIds) {

        buildImageDAO.deleteByBuildId(actingUserId, buildId);

        int sortOrder = 0;
        for (Integer imageId : imageIds) {
            buildImageDAO.create(
                    actingUserId,
                    buildId,
                    imageId,
                    sortOrder++);
        }
    }
}
