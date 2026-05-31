package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.BuildDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.Build;
import com.jayrodharv.ngosmpwebappspringboot.model.BuildVM;
import com.jayrodharv.ngosmpwebappspringboot.model.Image;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.util.List;
import java.util.Optional;

/**
 * Business logic for Builds and their images.
 */
@Service
public class BuildService {

    private final BuildDAO     buildDAO;
    private final ImageService imageService;

    public BuildService(BuildDAO buildDao, ImageService imageService) {
        this.buildDAO     = buildDao;
        this.imageService = imageService;
    }

    public List<BuildVM> findAll(int page, int pageSize,
                                  String worldId, String buildTypeId,
                                  String userDisplayName) {
        return buildDAO.findAll(pageSize, page * pageSize, worldId, buildTypeId, userDisplayName);
    }

    public Optional<BuildVM> findById(String buildId) {
        Optional<BuildVM> opt = buildDAO.findById(buildId);
        opt.ifPresent(b -> b.setImages(buildDAO.findImages(buildId)));
        return opt;
    }

    public List<BuildVM> findByUser(String userId) {
        return buildDAO.findByUser(userId);
    }

    public void create(Build build) {
        buildDAO.insert(build);
    }

    public void update(Build build) {
        buildDAO.update(build);
    }

    public void delete(String buildId) {
        buildDAO.deleteById(buildId);
    }

    /** Upload one image and attach it to a build. */
    public void addImage(String buildId, MultipartFile file, boolean isPrimary) throws IOException {
        Image img = imageService.store(file);
        List<Image> existing = buildDAO.findImages(buildId);
        buildDAO.addImage(buildId, img.getImageId(), isPrimary, existing.size());
    }

    public void removeImage(String buildId, int imageId) {
        buildDAO.removeImage(buildId, imageId);
        imageService.delete(imageId);
    }
}
