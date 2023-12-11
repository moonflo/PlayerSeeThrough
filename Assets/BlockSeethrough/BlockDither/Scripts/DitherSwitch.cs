using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.Universal;

public class DitherSwitch : MonoBehaviour
{
    // Start is called before the first frame update
    public bool ditherOn = false;
    private bool lastSwitch = false;
    void Start()
    {
        ditherOn = false;
    }

    void SetDitherOff()
    {
        ditherOn = false;
    }
    // Update is called once per frame
    void Update()
    {
        Renderer renderer = GetComponent<Renderer>();
                            
        Material uniqueMaterial = renderer.material;
        if (uniqueMaterial.HasProperty("_EnableBlockDither"))
        {
            if (ditherOn)
            {
                if (lastSwitch != ditherOn)
                {
                    uniqueMaterial.EnableKeyword("_ENABLEBLOCKDITHER_ON");
                    lastSwitch = true;
                    Invoke(nameof(SetDitherOff), 0.5f);
                }
            }
            else
            {
                if (lastSwitch != ditherOn)
                {
                    uniqueMaterial.DisableKeyword("_ENABLEBLOCKDITHER_ON");
                    lastSwitch = false;
                }
                
                
            }
        }
        else
        {
            Debug.Log("[DitherSwitch] material does contain properity called _EnableBlockDither");
        }
    }
}
