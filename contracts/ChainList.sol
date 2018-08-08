pragma solidity ^0.4.18;

import "./Ownable.sol";

contract ChainList is Ownable {

  // custom types
  struct Article {
    uint id;
    address seller;
    address buyer;
    string name;
    string description;
    uint256 price;
  }

  // state variables
  mapping (uint => Article) public articles;
  uint articleCounter;

  // events
  event LogSellArticle(
    uint indexed _id,
    address indexed _seller,
    string _name,
    uint256 _price
  );

  event LogBuyArticle(
    uint indexed _id,
    address indexed _seller,
    address indexed _buyer,
    string _name,
    uint256 _price
  );


  //deactivate the contracts
  function kill() public onlyOwner {
    selfdestruct(owner);
  }



  // sell an article
  function sellArticle(string _name, string _description, uint256 _price) public {
    // a new articles
    articleCounter++;

    articles[articleCounter] = Article(
      articleCounter,
      msg.sender,
      0x0,
      _name,
      _description,
      _price
    );

    LogSellArticle(articleCounter, msg.sender, _name, _price);
  }

  // fetch the number of articles in the contracts
  function getNumberOfArticles() public view returns (uint) {
    return articleCounter;
  }

  // fetch and return all article IDs for articles still for scale
  function getArticlesForSale() public view returns (uint[]) {
    //prepare output array
    uint[] memory articleIds = new uint[](articleCounter);

    uint numberOfArticlesForSale = 0;

    //iterate over articles
    for(uint i = 1; i <= articleCounter; i++) {
      // keep the ID if the article is still for sale
      if(articles[i].buyer == 0x0) {
        articleIds[numberOfArticlesForSale] = articles[i].id;
        numberOfArticlesForSale++;
      }
    }

    // copy the articleIDs array into a smaller forSale array
    uint[] memory forSale = new uint[](numberOfArticlesForSale);
    for(uint j = 0; j < numberOfArticlesForSale; j++) {
      forSale[j] = articleIds[j];
    }
    return forSale;
  }

  // buy an article
  function buyArticle(uint _id) payable public {
    // check whether there is an article for sale
    require(articleCounter > 0);

    // we check that the article exists
    require(_id > 0 && _id <= articleCounter);

    // we retrieve the article from the mapping
    Article storage article = articles[_id];

    // check if the article has been Sold
    require(article.buyer == 0x0);

    // don't allow the seller to buy their own article
    require(msg.sender != article.seller);

    // check if the value sent corresponds to the price of the article
    require(msg.value == article.price);

    // keep track of the buyers information
    article.buyer = msg.sender;

    // the buyer can pay the seller
    article.seller.transfer(msg.value);

    //trigger the event
    LogBuyArticle(_id, article.seller, article.buyer, article.name, article.price);
  }
}
