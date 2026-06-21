package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.config.CustomUserDetails;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.BuildImageDAO;
import com.jayrodharv.ngosmpwebappspringboot.dao.TagDAO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildFormDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.build.BuildListDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.NewTagDTO;
import com.jayrodharv.ngosmpwebappspringboot.dto.tag.TagDTO;
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

    public PageResult<BuildListDTO> getBuilds(PageRequest request) {
        log.debug("Retrieving build list for request: page={}, size={}, search={}, tagIds={}, descending={}",
            request.page(),
            request.size(),
            request.search(),
            request.tagIds().toString(),
            request.descending() ? "true" : "false"
        );

        PageResult<BuildListDTO> builds;
        try {

            builds = buildDAO.getBuilds(request);

            List<Integer> buildIds = builds
                    .items()
                    .stream()
                    .map(BuildListDTO::buildId)
                    .toList();

            Map<Integer, List<TagDTO>> tagsByBuild = tagDAO.getTagsForBuilds(buildIds);

            for (BuildListDTO build : builds.items()) {
                build
                    .tags()
                    .addAll(tagsByBuild.getOrDefault(tagsByBuild, List.of()));
            }
        } catch (Exception e) {
            log.error("Failed to retrieve build list", e);
            throw e;
        }

        return builds;
    }

    public Integer createBuild(BuildFormDTO dto) {

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
