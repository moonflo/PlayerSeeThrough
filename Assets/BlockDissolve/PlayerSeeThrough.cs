using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerSeeThrough : MonoBehaviour
{
    public enum PlayerIdentifier
    {
        MainPlayer,
        Follower
    }

    public PlayerIdentifier playerID = PlayerIdentifier.MainPlayer;
    public Vector4 playerPosition;
    // Start is called before the first frame update
    void Start()
    {
        playerPosition = this.transform.position;
        Shader.SetGlobalVector("_TargetSeeThrough", playerPosition);
    }
    
    
    
    // Update is called once per frame
    void Update()
    {
        playerPosition = this.transform.position;
        Shader.SetGlobalVector("_TargetSeeThrough", playerPosition);
    }
}
