package com.jayrodharv.ngosmpwebappspringboot.service;

import com.jayrodharv.ngosmpwebappspringboot.dao.WorldDAO;
import com.jayrodharv.ngosmpwebappspringboot.model.World;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class WorldService {

    private final WorldDAO worldDao;

    public WorldService(WorldDAO worldDao) { this.worldDao = worldDao; }

    public List<World> findAll()                  { return worldDao.findAll(); }
    public Optional<World> findById(String id)    { return worldDao.findById(id); }
    public void create(World world)               { worldDao.insert(world); }
    public void update(World world)               { worldDao.update(world); }
    public void delete(String worldId)            { worldDao.deleteById(worldId); }
}
