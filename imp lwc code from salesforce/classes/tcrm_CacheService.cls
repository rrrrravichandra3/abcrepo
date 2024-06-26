/**
 * @description       : Service to store and retrieve data from cache partition
 * @author            : Kyle Moseley (kmoseley)
 * @last modified on  : 12-14-2022
 * @last modified by  : Kyle Moseley (kmoseley)
 */
public class tcrm_CacheService {

    /**
     * @description         gets the value stored in the partition based on key
     * @param   cacheKey    String - specific key stored in the partion
     * @return  value       String - value of keypair passed into method                    
     */
    public static Object getFromOrgCache(String cacheKey) {
		Cache.OrgPartition orgPart = Cache.Org.getPartition('local.BeameryAccessToken');
        System.debug(orgPart);
        System.debug(cacheKey + ' exists? ' +orgPart.contains(cacheKey));
        if (orgPart.contains(cacheKey)) {
		    return orgPart.get(cacheKey);
		}else {
			return null;
		}
	}

    /**
     * @description         puts the key-value pair in the cache partition
     * @param   cacheKey    key   
     * @param   value       value 
     */
    public static void putInOrgCache(String cacheKey,Object value) {
        Cache.OrgPartition orgPart = Cache.Org.getPartition('local.BeameryAccessToken');
        orgPart.put(cacheKey, value);
	}
}