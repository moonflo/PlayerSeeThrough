using System;
using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;

public class OcclusionDetection : MonoBehaviour
{
    // Since we need see through the wall the observation player, we need it transform, currently we assume it's a box
    private Transform m_boxTransform;
    
    // Using for ray cast
    public GameObject lastHitGameObject;
    public Camera viewCamera;
    public List<Vector3> occlusionPoints;
    public LayerMask layer;
    public Vector3 originalScale = new(0.5f, 0.5f, 0.5f);
    
    
    public List<Vector3> occlusionEndPoints;
    
    // Start is called before the first frame update
    void Start()
    {
        if (m_boxTransform == null)
        {
            PlayerSeeThrough player = (PlayerSeeThrough)GameObject.FindObjectOfType(typeof(PlayerSeeThrough));
            if (player == null)
            {
                Debug.LogWarning("[OcclusionDetection]No Player Transform got, " +
                                 "must give a player script for a player object in current scene.");
            }
            m_boxTransform = player.transform;
        }
        viewCamera = Camera.main;
    }

    void ClearDither()
    {
        
    }

    void GetBoundBoxEdgePoints(List<Vector3> points)
    {
        points.Clear();
        Vector3 centerPosition = m_boxTransform.position;
        Vector3 scale = m_boxTransform.localScale;
        
        
        // (+++) (++-) (+-+) (+--) 
        points.Add(new Vector3(
            centerPosition.x + scale.x * originalScale.x, 
            centerPosition.y + scale.y * originalScale.y, 
            centerPosition.z + scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x + scale.x * originalScale.x, 
            centerPosition.y + scale.y * originalScale.y, 
            centerPosition.z - scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x + scale.x * originalScale.x, 
            centerPosition.y - scale.y * originalScale.y, 
            centerPosition.z + scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x + scale.x * originalScale.x, 
            centerPosition.y - scale.y * originalScale.y, 
            centerPosition.z - scale.z * originalScale.z));

        
        // (-++) (-+-) (--+) (---) 
        points.Add(new Vector3(
            centerPosition.x - scale.x * originalScale.x, 
            centerPosition.y + scale.y * originalScale.y, 
            centerPosition.z + scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x - scale.x * originalScale.x, 
            centerPosition.y + scale.y * originalScale.y, 
            centerPosition.z - scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x - scale.x * originalScale.x, 
            centerPosition.y - scale.y * originalScale.y, 
            centerPosition.z + scale.z * originalScale.z));
        points.Add(new Vector3(
            centerPosition.x - scale.x * originalScale.x, 
            centerPosition.y - scale.y * originalScale.y, 
            centerPosition.z - scale.z * originalScale.z));
    }
    
    
    // Update is called once per frame
    void Update()
    {
        Vector3 origin = viewCamera.transform.position;
        if (m_boxTransform != null)
        {
            List<Vector3> endPoints = new List<Vector3>();
            GetBoundBoxEdgePoints(endPoints);
            occlusionEndPoints = endPoints;
            foreach (var endPoint in endPoints)
            {
                Vector3 dir = (endPoint - origin).normalized;
                float distance = Vector3.Distance(endPoint, origin);
                Ray castRay = new Ray(origin, dir);
                RaycastHit hitInfos;
                if (Physics.Raycast(castRay, out hitInfos, distance, layer))
                {
                    lastHitGameObject = hitInfos.transform.gameObject;
                    occlusionPoints.Add(hitInfos.point);
                    DitherSwitch hitObjectSwitch = lastHitGameObject.GetComponent<DitherSwitch>();
                    if (hitObjectSwitch != null)
                    {
                        hitObjectSwitch.ditherOn = true;
                    }
                }
            }
        }
        else
        {
            Debug.Log("[OcclusionDetection]No Player Transform got, " +
                      "must give a player script for a player object in current scene.");
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        foreach (var VARIABLE in occlusionPoints)
        {
            Gizmos.DrawWireSphere(VARIABLE, 0.1f);
        }
        occlusionPoints.Clear();
        
        // Draw bounding Box
        Gizmos.color = Color.blue;
        if (occlusionEndPoints.Count == 8)
        {
            Gizmos.DrawLine(occlusionEndPoints[0], occlusionEndPoints[1]);
            Gizmos.DrawLine(occlusionEndPoints[0], occlusionEndPoints[2]);
            Gizmos.DrawLine(occlusionEndPoints[2], occlusionEndPoints[3]);
            Gizmos.DrawLine(occlusionEndPoints[1], occlusionEndPoints[3]);
        
            Gizmos.DrawLine(occlusionEndPoints[4], occlusionEndPoints[6]);
            Gizmos.DrawLine(occlusionEndPoints[5], occlusionEndPoints[7]);
            Gizmos.DrawLine(occlusionEndPoints[4], occlusionEndPoints[5]);
            Gizmos.DrawLine(occlusionEndPoints[6], occlusionEndPoints[7]);
        
            Gizmos.DrawLine(occlusionEndPoints[0], occlusionEndPoints[4]);
            Gizmos.DrawLine(occlusionEndPoints[1], occlusionEndPoints[5]);
            Gizmos.DrawLine(occlusionEndPoints[3], occlusionEndPoints[7]);
            Gizmos.DrawLine(occlusionEndPoints[2], occlusionEndPoints[6]);
            occlusionEndPoints.Clear();
        }
        else
        {
            // Debug.Log("[Occlusion Detection] OnGizmos, we don't have 8 end point.");
        }

    }
}
